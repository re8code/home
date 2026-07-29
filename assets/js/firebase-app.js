// Firestore(firebase-client.js)와 Authentication(firebase-auth.js)이
// 동일한 Firebase App 인스턴스를 공유하도록 하는 싱글턴.
import { initializeApp, getApps, getApp } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js';
import { FIREBASE_CONFIG } from './firebase-config.js';

export function getFirebaseApp() {
  return getApps().length ? getApp() : initializeApp(FIREBASE_CONFIG);
}
