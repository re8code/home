# "원장님의 낙서" Firebase 연결 작업 결과 보고

- 작성일: 2026-07-30
- 산출물: `./assets/js/firebase-config.js`, `./assets/js/firebase-client.js`, `./assets/js/admin-auth.js`, `./graffiti.html`(수정), `./graffiti-detail.html`(수정)

## 1. 작업 개요

`task.md`의 지시에 따라 "원장님의 낙서" 게시판(`graffiti.html`, `graffiti-detail.html`)을 Firebase(Firestore)와 연결하는 코드를 추가했습니다.
지시대로 **Firebase config 파일만 임시(placeholder) 값**으로 구성했고, 나머지 연동 코드(Firestore 조회·수정·삭제, 목록/상세 페이지 연결)는 실제 동작하는 정식 코드로 작성했습니다.
아울러 "수정"·"삭제" 기능 버튼을 상세 페이지에 추가하고, 두 기능 모두 원장 전용 비밀번호(`sungwons`) 인증을 통과해야 실행되도록 구성했습니다.

## 2. 작업 과정 (순차적 진행 내역)

### 2-1. 기존 구조 파악
- `graffiti.html`(목록), `graffiti-detail.html`(상세), `assets/js/graffiti-data.js`(임시 데이터 24건)의 기존 렌더링 로직을 확인.
- 기존 리스트/상세 페이지는 `GRAFFITI_POSTS` 배열을 직접 참조하는 동기(synchronous) 구조였음을 확인.

### 2-2. Firebase config 파일 분리 (임시 값)
- `assets/js/firebase-config.js` 신규 작성.
- `apiKey`, `projectId` 등은 모두 `TEMP_*` 형태의 placeholder 값으로 채우고, 파일 최상단에 "실제 Firebase 콘솔에서 발급받은 값으로 교체 필요"라는 안내 주석을 명시.
- Firestore 컬렉션명(`graffiti_posts`)도 이 파일에서 함께 관리하도록 구성.

### 2-3. Firestore 연동 클라이언트 작성
- `assets/js/firebase-client.js` 신규 작성 (ES Module).
- Firebase JS SDK(v10.12.2, CDN 모듈)로 `initializeApp` → `getFirestore` 연결.
- `fetchPosts()`, `updatePost(docId, data)`, `deletePost(docId)` 3개 함수를 구현하여 목록 조회·수정·삭제를 담당.
- 모든 함수는 실패(네트워크 오류, 임시 config로 인한 인증 실패 등) 시 예외를 잡아 안전하게 `null`/`false`를 반환하도록 처리.

### 2-4. 목록/상세 페이지에 Firebase 연동 반영
- `graffiti.html`, `graffiti-detail.html`의 기존 `<script>` 블록을 `<script type="module">`로 전환.
- 페이지 로드 시 `fetchPosts()`를 먼저 호출해 Firestore 데이터를 조회하고, 데이터가 없거나 실패하면 기존 `graffiti-data.js`의 임시 데이터로 자동 대체(fallback)하도록 구성.
- 이 구조 덕분에 향후 `firebase-config.js`의 값을 실제 프로젝트 값으로 교체하기만 하면, 나머지 코드 수정 없이 실 데이터 연동으로 전환됩니다.

### 2-5. "수정"/"삭제" 기능 버튼 및 원장 인증 추가
- `assets/js/admin-auth.js` 신규 작성: 비밀번호(`sungwons`) 검증 로직과, 사이트 톤에 맞춘 커스텀 인증 모달(`requestAdminPassword`)·삭제 확인 모달(`confirmAction`)을 구현.
- `graffiti-detail.html` 하단에 "수정", "삭제", "목록" 버튼을 배치.
  - **수정**: 비밀번호 인증 통과 → 제목/본문을 편집할 수 있는 모달 오픈 → 저장 시 Firestore 문서(`updatePost`) 갱신, 화면에도 즉시 반영.
  - **삭제**: 비밀번호 인증 통과 → 삭제 확인 모달 → 확정 시 Firestore 문서(`deletePost`) 삭제 후 목록 페이지로 이동.
  - 원장 인증 없이는 두 기능 모두 실행되지 않으며, 틀린 비밀번호 입력 시 오류 메시지가 표시됩니다.

### 2-6. 중간 점검 중 발견한 문제와 수정
- claude-in-chrome으로 로컬 서버(`python3 -m http.server`)를 띄워 `graffiti-detail.html`을 열어본 결과, 임시(가짜) 프로젝트 ID로 인해 Firestore의 실시간 연결(Listen 채널)이 503 응답을 받으며 **무한 재시도**, 페이지가 응답 없이 멈추는 문제를 발견.
- 이를 해결하기 위해 `firebase-client.js`에 **6초 타임아웃**(`withTimeout`)을 추가하여, 응답이 없으면 실패로 간주하고 즉시 로컬 데이터로 대체되도록 수정.
- 또한 타임아웃 발생 시 Firestore 연결을 `terminate()`로 종료하고 리셋하여, 백그라운드에서 재시도 요청이 계속 쌓이지 않도록 보완.

## 3. 기술 구성 요약

| 파일 | 역할 |
| --- | --- |
| `assets/js/firebase-config.js` | Firebase 프로젝트 설정값(임시/placeholder)과 컬렉션명 정의 |
| `assets/js/firebase-client.js` | Firestore 초기화, `fetchPosts`/`updatePost`/`deletePost`, 타임아웃·재연결 처리 |
| `assets/js/admin-auth.js` | 원장 비밀번호 검증, 인증 모달, 삭제 확인 모달 (네이티브 `confirm()` 미사용) |
| `graffiti.html` | 모듈 스크립트로 전환, Firestore 조회 결과 우선 사용 → 실패 시 로컬 데이터 폴백 |
| `graffiti-detail.html` | 위와 동일한 데이터 소스 구조 + "수정"/"삭제" 버튼과 인증 플로우 추가 |

## 4. 검증 (claude-in-chrome 중간 점검)

로컬 정적 서버로 페이지를 구동한 뒤 브라우저에서 직접 다음을 확인했습니다.

- 상세 페이지 최초 진입 시 Firestore 요청이 타임아웃(약 6초) 후 로컬 데이터로 정상 대체되어 렌더링됨을 확인.
- "수정" 버튼 클릭 → 비밀번호 모달 노출 → 오답 입력 시 "비밀번호가 올바르지 않습니다" 오류 표시 확인.
- 정답(`sungwons`) 입력 → 수정 모달에 기존 제목/본문이 채워진 상태로 오픈됨을 확인.
- 제목을 수정 후 저장 → 화면에 즉시 반영됨을 확인(로컬 fallback 모드이므로 `console.warn`으로 "임시 데이터, 실 저장은 프로젝트 연동 후 반영" 안내).
- "삭제" 버튼 클릭 → 비밀번호 인증 → 삭제 확인 모달에서 "취소" 클릭 시 삭제되지 않고 유지됨을 확인.
- 다시 삭제 진행 → 확인 모달에서 "삭제" 클릭 → 목록 페이지(`graffiti.html`)로 정상 이동, 목록도 정상 렌더링됨을 확인.

## 5. 현재 상태의 한계 및 안내

- **config는 임시 값**이므로, 현재 상태에서는 실제 Firestore 데이터베이스에 읽기/쓰기가 반영되지 않고, 로컬 임시 데이터(`graffiti-data.js`) 기준으로 화면 동작만 시연되는 상태입니다.
- 실제 Firebase 프로젝트를 생성한 뒤 `assets/js/firebase-config.js`의 값만 교체하면, 별도 코드 수정 없이 실 데이터 연동(조회/수정/삭제)이 바로 동작하도록 구성했습니다.
- 비밀번호 인증은 정적 사이트의 **클라이언트 측 검증**입니다. 브라우저 개발자 도구로 소스를 열람하면 비밀번호 값이 노출될 수 있어, 완전한 보안 인증은 아닙니다. 운영 전환 시 Firebase Authentication 등 서버 측 인증으로 교체를 권장합니다.

## 6. 향후 개선 제안 (선택 사항)

- 실제 Firebase 프로젝트 생성 및 `firebase-config.js` 값 교체, Firestore 보안 규칙(원장만 쓰기 가능하도록) 설정
- 비밀번호 인증을 Firebase Authentication 기반으로 교체(현재는 클라이언트 하드코딩 비밀번호)
- 게시글 신규 작성(등록) 기능 추가 여부 검토
