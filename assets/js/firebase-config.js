// Firebase 콘솔 > 프로젝트 설정 > 일반 > 내 앱에서 발급받은 실제 프로젝트 설정값입니다.
export const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyA7-iI-yV3S0NE2dmxEgxA8XurU0swAuSc',
  authDomain: 'graffiti-3b1fc.firebaseapp.com',
  projectId: 'graffiti-3b1fc',
  storageBucket: 'graffiti-3b1fc.firebasestorage.app',
  messagingSenderId: '64211978673',
  appId: '1:64211978673:web:209a75d2a9daec3c89d590',
};

// "원장님의 낙서" 게시글을 저장할 Firestore 컬렉션 이름
export const GRAFFITI_COLLECTION = 'graffiti_posts';

// 원장 인증(Firebase Authentication)에 사용할 관리자 계정 이메일.
// Firebase 콘솔 > Authentication > Sign-in method에서 이메일/비밀번호 방식을 켠 뒤,
// 아래와 동일한 이메일로 사용자를 추가해야 합니다.
export const ADMIN_EMAIL = 'won@re8code.com';

// firebase-config.js가 아직 실제 값으로 교체되지 않은 임시 상태인지 여부.
// (이 값에 의존하는 다른 파일들이 각자 판단 로직을 중복 구현하지 않도록 여기서 한 번만 계산)
export const IS_PLACEHOLDER_CONFIG = FIREBASE_CONFIG.projectId.startsWith('TEMP_');
