// 원장 전용 로그인(Firebase Authentication) 연동 코드.
// firebase-config.js의 값이 실제 프로젝트 값으로 교체되어야 동작합니다.
import {
  getAuth,
  signInWithEmailAndPassword,
  signOut,
} from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js';
import { ADMIN_EMAILS } from './firebase-config.js';
import { getFirebaseApp } from './firebase-app.js';

let auth = null;

function getAuthInstance() {
  if (!auth) {
    auth = getAuth(getFirebaseApp());
  }
  return auth;
}

// 입력된 주소를 비교 가능한 형태로 맞춥니다. Firebase는 이메일을 소문자로 보관하므로
// 사용자가 대문자로 입력해도 같은 계정으로 취급되어야 합니다.
function normalize(email) {
  return String(email ?? '').trim().toLowerCase();
}

// 그 주소가 원장 계정 목록에 있는지 확인합니다.
export function isAdminEmail(email) {
  return ADMIN_EMAILS.includes(normalize(email));
}

// 현재 브라우저 세션에 원장 계정으로 로그인되어 있는지 확인합니다.
// (같은 브라우저에서 한 번 로그인하면, 이후 페이지 이동 시에도 로그인 상태가 유지됩니다.)
export function isAdminSignedIn() {
  return isAdminEmail(getAuthInstance().currentUser?.email);
}

// 이메일+비밀번호로 원장 계정 로그인을 시도합니다. 성공 시 true, 실패 시 false를 반환합니다.
// 목록에 없는 주소는 Firebase에 요청을 보내지 않고 바로 거절합니다 — 남의 주소로
// 비밀번호를 던져보는 통로가 되지 않도록.
export async function signInAdmin(email, password) {
  const address = normalize(email);
  if (!isAdminEmail(address)) return false;
  try {
    const credential = await signInWithEmailAndPassword(getAuthInstance(), address, password);
    return isAdminEmail(credential.user.email);
  } catch (error) {
    console.warn('[Firebase Auth] 로그인 실패:', error);
    return false;
  }
}

export async function signOutAdmin() {
  await signOut(getAuthInstance());
}
