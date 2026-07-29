# Firebase Authentication(B안) 적용 결과 보고

- 작성일: 2026-07-30
- 산출물: `./assets/js/firebase-app.js`(신규), `./assets/js/firebase-auth.js`(신규), `./firestore.rules`(신규), `./assets/js/firebase-config.js`(수정), `./assets/js/firebase-client.js`(수정), `./assets/js/admin-auth.js`(수정)

## 1. 배경

지난 보고서(`2026-07-30-graffiti-write-and-production-mode.md`)에서 안내드린 두 가지 선택지 중 **B안(Firebase Authentication 도입)**으로 확정되어 반영했습니다.
기존에는 "수정"·"삭제"·"글 작성" 버튼을 누르면 브라우저 JS에서 문자열(`sungwons`)만 비교했지만, 이제는 **Firebase Authentication을 통한 실제 로그인**으로 인증하고, Firestore 보안 규칙도 로그인 여부로 쓰기를 제한할 수 있도록 구성했습니다.

## 2. 변경 내역

### 2-1. `assets/js/firebase-app.js` (신규)
- Firestore(`firebase-client.js`)와 Authentication(`firebase-auth.js`)이 동일한 Firebase App 인스턴스를 공유하도록 하는 싱글턴을 분리했습니다. (Firebase는 같은 이름의 App을 두 번 초기화하면 오류가 나기 때문에 필요한 구조입니다.)

### 2-2. `assets/js/firebase-config.js`
- `ADMIN_EMAIL` 추가: 원장 계정으로 사용할 이메일(`admin@recode.ai.kr`, 임시값이며 원하시는 값으로 변경 가능).
- `IS_PLACEHOLDER_CONFIG` 추가: config가 아직 임시값인지 여부를 한 곳에서 판단해 다른 파일들이 공유하도록 정리했습니다.

### 2-3. `assets/js/firebase-auth.js` (신규)
- `signInAdmin(password)`: `ADMIN_EMAIL` + 입력한 비밀번호로 Firebase Authentication에 실제 로그인을 시도합니다.
- `isAdminSignedIn()`: 현재 브라우저 세션에 원장 계정으로 이미 로그인되어 있는지 확인합니다(로그인 상태는 Firebase가 브라우저에 유지하므로, 한 번 로그인하면 페이지를 이동해도 다시 로그인할 필요가 없습니다).
- `signOutAdmin()`: 로그아웃(현재 UI에서는 아직 호출하는 곳이 없으며, 필요 시 추가 가능).

### 2-4. `assets/js/admin-auth.js`
- 기존과 동일하게 "비밀번호 한 칸 입력" 모달 UX는 그대로 유지했습니다.
- 내부 로직만 분기: config가 아직 임시값이면 기존처럼 로컬 문자열(`sungwons`)과 비교(개발용), 실제 config가 반영되면 `signInAdmin()`으로 Firebase Authentication 실제 로그인을 수행합니다.
- 이미 로그인된 세션이 있으면 모달 자체를 띄우지 않고 즉시 통과합니다.

### 2-5. `assets/js/firebase-client.js`
- Firebase App 초기화를 `firebase-app.js`의 공유 싱글턴으로 교체(중복 초기화 오류 방지).
- `isPlaceholderConfig`를 자체 계산하던 것을 `firebase-config.js`의 `IS_PLACEHOLDER_CONFIG`를 가져다 쓰도록 정리(중복 로직 제거).

### 2-6. `firestore.rules` (신규)
- Firebase 콘솔의 "규칙" 탭에 그대로 붙여넣을 수 있는 규칙 파일을 준비했습니다.
  ```
  match /graffiti_posts/{postId} {
    allow read: if true;
    allow write: if request.auth != null
      && request.auth.token.email == "admin@recode.ai.kr";
  }
  ```
  → 목록/상세는 누구나 볼 수 있고, **로그인한 원장 계정만** 등록·수정·삭제가 가능합니다.

## 3. 검증

- 로컬 서버로 `graffiti-detail.html`을 구동해 콘솔 오류 없이 정상 렌더링됨을 확인.
- "수정" 버튼 클릭 → 비밀번호 모달 → `sungwons` 입력 → 여전히 개발용(로컬) 비밀번호 경로로 즉시 통과함을 확인(= 임시 config 상태에서는 Firebase Auth 네트워크 호출 없이 기존처럼 동작하여, 실제 프로젝트 연동 전에도 화면 흐름을 계속 점검할 수 있음).

## 4. 지금부터 대표님이 콘솔에서 하셔야 하는 일

1. **Firebase Authentication 활성화**: 콘솔 좌측 메뉴 "빌드 > Authentication" → "시작하기" → "Sign-in method" 탭에서 **이메일/비밀번호** 제공업체를 사용 설정.
2. **원장 계정 생성**: "Authentication > Users" 탭 → "사용자 추가" → 이메일은 `assets/js/firebase-config.js`의 `ADMIN_EMAIL`과 **반드시 동일하게**(다른 이메일을 쓰고 싶으시면 그 값으로 이 파일도 함께 바꿔드릴 테니 알려주세요), 비밀번호는 원하시는 값으로 설정(꼭 `sungwons`일 필요는 없습니다 — 이제 이 비밀번호는 Firebase 서버가 검증하므로 소스코드에 노출되지 않습니다).
3. **Firestore 규칙 게시**: `firestore.rules` 파일 내용을 콘솔의 "Firestore Database > 규칙" 탭에 붙여넣고 "게시".
4. **웹 앱 config 값 발급 및 전달**: 아직 안 하셨다면 "프로젝트 설정 > 일반 > 내 앱"에서 값을 받아 저에게 전달(또는 직접 `firebase-config.js`에 입력).

## 5. 제가 이어서 할 수 있는 일

- 실제 config 값을 받으면 `firebase-config.js`에 반영하고, 로그인부터 등록·수정·삭제까지 다시 전체 검증
- `ADMIN_EMAIL`을 원하시는 이메일로 변경 반영 (`firebase-config.js` + `firestore.rules` 동시 수정)
- 필요 시 "로그아웃" 버튼 UI 추가 (현재는 로직만 준비되어 있고 화면 버튼은 없음)
- 기존 임시 데이터 24건을 Firestore로 옮기는 1회성 스크립트 작성(서비스 계정 키 발급은 대표님 몫)

## 6. 참고 — 이번 변경으로 달라지는 점

- 이전에는 소스코드(`admin-auth.js`)에 비밀번호(`sungwons`)가 그대로 노출되어 있었지만, 실제 config 적용 후에는 이 값이 더 이상 쓰이지 않고 Firebase 서버가 로그인을 검증하므로 **소스에 비밀번호가 노출되지 않습니다.**
- 로그인 세션이 브라우저에 유지되므로, 원장이 한 번 로그인하면 이후 같은 브라우저에서는 매번 비밀번호를 다시 입력하지 않아도 됩니다.
