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

// 원장 인증(Firebase Authentication)에 사용할 관리자 계정 목록 — ARCHITECTURE.md ADR D4.
// 여기 없는 주소는 로그인 요청조차 보내지 않고, firestore.rules도 이 목록만 쓰기를 허용한다.
// 반드시 소문자로 적는다(로그인 입력은 소문자로 정규화해 대조한다).
//
// 값을 고칠 때는 **세 곳을 함께** 고치고 콘솔에 규칙을 재게시해야 한다 —
// 이 파일 · firestore.rules · scripts/check-device.sh 의 FIXED_ADMIN_MAILS.
// (셋의 일치는 ./scripts/check-device.sh 가 매번 대조한다.)
// 콘솔 > Authentication > Sign-in method 에서 이메일/비밀번호 방식을 켜고,
// 아래 각 주소를 사용자로 등록해야 실제로 로그인된다.
// 콘솔 Owner와 이 목록은 별개다 — Owner는 둘(won·biz)이지만 낙서장 쓰기는 하나뿐이다.
// 글에 작성자가 기록되지 않아 계정을 늘려도 구분되는 것이 없기 때문(ADR D4).
export const ADMIN_EMAILS = [
  'triwon20@gmail.com', // 제거 예정 — won 계정으로 쓰기가 검증된 뒤 (ADR D4 이행 2단계)
  'won@re8code.com',
];

// firebase-config.js가 아직 실제 값으로 교체되지 않은 임시 상태인지 여부.
// (이 값에 의존하는 다른 파일들이 각자 판단 로직을 중복 구현하지 않도록 여기서 한 번만 계산)
export const IS_PLACEHOLDER_CONFIG = FIREBASE_CONFIG.projectId.startsWith('TEMP_');
