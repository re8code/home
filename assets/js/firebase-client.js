// "원장님의 낙서" 게시판의 Firebase(Firestore) 연동 코드.
// firebase-config.js의 값만 실제 프로젝트 값으로 교체하면 그대로 동작합니다.
import {
  getFirestore,
  collection,
  getDocs,
  addDoc,
  doc,
  updateDoc,
  deleteDoc,
  query,
  orderBy,
  terminate,
} from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js';
import { GRAFFITI_COLLECTION, IS_PLACEHOLDER_CONFIG } from './firebase-config.js';
import { getFirebaseApp } from './firebase-app.js';

let db = null;

// 임시(placeholder) config로는 실제 프로젝트가 없어 Firestore 요청이 응답 없이
// 재시도만 반복할 수 있어, 일정 시간 내 응답이 없으면 실패로 간주하고 폴백합니다.
const REQUEST_TIMEOUT_MS = 6000;

function withTimeout(promise, ms) {
  return Promise.race([
    promise,
    new Promise((_, reject) => setTimeout(() => reject(new Error('Firebase 요청 시간 초과')), ms)),
  ]);
}

function getDb() {
  if (!db) {
    db = getFirestore(getFirebaseApp());
  }
  return db;
}

// 요청이 시간 초과로 실패하면 백그라운드에서 재연결을 계속 시도하지 않도록
// 연결을 종료하고, 다음 호출 시 새로 초기화하도록 리셋합니다.
async function resetDb() {
  const stale = db;
  db = null;
  if (stale) {
    try {
      await terminate(stale);
    } catch {
      // 종료 실패는 무시 (이미 임시 config로 정상 연결되지 않은 상태)
    }
  }
}

// Firestore에서 게시글 목록을 최신순으로 가져옵니다.
// 정상 조회 시 배열(글이 없으면 빈 배열)을 반환하고,
// 조회 자체가 실패(임시 config, 네트워크 오류, 시간 초과 등)한 경우에만 null을 반환합니다.
export async function fetchPosts() {
  if (IS_PLACEHOLDER_CONFIG) return null;
  try {
    const database = getDb();
    const q = query(collection(database, GRAFFITI_COLLECTION), orderBy('id', 'desc'));
    const snapshot = await withTimeout(getDocs(q), REQUEST_TIMEOUT_MS);
    return snapshot.docs.map((d) => ({ docId: d.id, ...d.data() }));
  } catch (error) {
    console.warn('[Firebase] 게시글 조회 실패:', error);
    await resetDb();
    return null;
  }
}

// 게시글 등록. 성공 시 생성된 문서 ID, 실패(임시 config 포함) 시 null을 반환합니다.
export async function createPost(data) {
  if (IS_PLACEHOLDER_CONFIG) return null;
  try {
    const database = getDb();
    const ref = await withTimeout(addDoc(collection(database, GRAFFITI_COLLECTION), data), REQUEST_TIMEOUT_MS);
    return ref.id;
  } catch (error) {
    console.warn('[Firebase] 게시글 등록 실패:', error);
    await resetDb();
    return null;
  }
}

// 게시글 수정. 성공 시 true, 실패(임시 config 포함) 시 false를 반환합니다.
export async function updatePost(docId, data) {
  if (IS_PLACEHOLDER_CONFIG) return false;
  try {
    const database = getDb();
    await withTimeout(updateDoc(doc(database, GRAFFITI_COLLECTION, docId), data), REQUEST_TIMEOUT_MS);
    return true;
  } catch (error) {
    console.warn('[Firebase] 게시글 수정 실패:', error);
    await resetDb();
    return false;
  }
}

// 게시글 삭제. 성공 시 true, 실패(임시 config 포함) 시 false를 반환합니다.
export async function deletePost(docId) {
  if (IS_PLACEHOLDER_CONFIG) return false;
  try {
    const database = getDb();
    await withTimeout(deleteDoc(doc(database, GRAFFITI_COLLECTION, docId)), REQUEST_TIMEOUT_MS);
    return true;
  } catch (error) {
    console.warn('[Firebase] 게시글 삭제 실패:', error);
    await resetDb();
    return false;
  }
}
