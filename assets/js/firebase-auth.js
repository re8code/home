// 원장 전용 로그인(Firebase Authentication) 연동 코드.
// firebase-config.js의 값이 실제 프로젝트 값으로 교체되어야 동작합니다.
import {
  getAuth,
  signInWithEmailAndPassword,
  signOut,
} from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js';
import { FIREBASE_CONFIG, ADMIN_EMAIL } from './firebase-config.js';
import { getFirebaseApp } from './firebase-app.js';

let auth = null;

function getAuthInstance() {
  if (!auth) {
    auth = getAuth(getFirebaseApp());
  }
  return auth;
}

// 현재 브라우저 세션에 원장 계정으로 로그인되어 있는지 확인합니다.
// (같은 브라우저에서 한 번 로그인하면, 이후 페이지 이동 시에도 로그인 상태가 유지됩니다.)
export function isAdminSignedIn() {
  return getAuthInstance().currentUser?.email === ADMIN_EMAIL;
}

// 비밀번호로 원장 계정 로그인을 시도합니다. 성공 시 true, 실패 시 false를 반환합니다.
export async function signInAdmin(password) {
  try {
    const credential = await signInWithEmailAndPassword(getAuthInstance(), ADMIN_EMAIL, password);
    return credential.user.email === ADMIN_EMAIL;
  } catch (error) {
    console.warn('[Firebase Auth] 로그인 실패:', error);
    return false;
  }
}

export async function signOutAdmin() {
  await signOut(getAuthInstance());
}
