# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 개요

"Recode Coding" 홈페이지 — 빌드 도구/패키지 매니저 없는 순수 정적 사이트(HTML + Tailwind CDN + Vanilla JS ES Module). `index.html`이 저장소 루트에 있어 GitHub Pages 루트 배포와 그대로 호환된다.

## 개발 명령

- **로컬 서버 실행**: `python3 -m http.server 8765` (저장소 루트에서 실행 후 `http://localhost:8765/index.html` 접속). Firestore(`assets/js/firebase-client.js`)를 사용하는 `graffiti*.html`은 `file://`로 직접 열면 ES module import가 동작하지 않으므로 반드시 로컬 서버를 통해 확인해야 한다.
- **빌드/린트/테스트**: 없음. `package.json` 자체가 존재하지 않는다. 변경 확인은 브라우저에서 직접 페이지를 열어 눈으로 검증한다(가능하면 claude-in-chrome으로 중간 점검).

## 배포

- GitHub Pages, `main` 브랜치 `/ (root)` 소스로 배포. 커스텀 도메인은 저장소 루트의 `CNAME` 파일(`recode.ai.kr`)로 연결됨 — 이 파일을 삭제하거나 내용을 바꾸면 도메인 연결이 끊어지므로 주의.
- 자세한 절차/DNS 설정은 `report/2026-07-29-deployment-guide.md` 참고.

## 페이지 구조

루트의 각 `.html`이 독립된 페이지이며 공유 컴포넌트나 템플릿 시스템은 없다 — Tailwind 설정(브랜드 색상 `brand.50~950`, Pretendard 폰트 등)이 `<script>tailwind.config = {...}</script>` 블록으로 **페이지마다 중복 정의**되어 있다. 톤/색상을 바꿀 때는 모든 페이지 상단의 config 블록을 동일하게 맞춰야 한다.

- `index.html` — 랜딩 페이지 (회사 소개, 교육 철학, 1:1 상담 CTA)
- `graffiti.html` / `graffiti-detail.html` / `graffiti-new.html` — "원장님의 낙서" 게시판 (목록 / 상세·수정·삭제 / 작성). Firestore CRUD를 `assets/js/firebase-client.js`에서 가져와 사용하며, `<script type="module">` 인라인 블록에서 DOM과 연결한다.
- `mockup.html` — 훈련 코스 페이지 목업(Epic Games Store 레이아웃 참고, 실제 서비스 페이지 아님). Swiper(캐러셀)와 AOS(스크롤 애니메이션)를 CDN으로 추가 로드하는 유일한 페이지.
- 모든 페이지 하단에서 `assets/js/mobile-menu.js`를 `defer`로 로드해 모바일 내비게이션 토글(`#mobile-menu-btn` / `#mobile-menu`)을 처리한다.
- `assets/image/` — 외부에서 가져온 로고·아이콘 등 이미지 리소스(예: `mockup.html` Language 카드의 언어별 로고 PNG). 각 파일의 출처·라이선스는 도입 시점의 `report/*.md`에 기록되어 있으니, 재배포 범위를 확인하려면 해당 보고서를 참고한다.

## Firebase 연동 (`assets/js/`)

"원장님의 낙서" 게시판 전용. 파일별 역할:

- `firebase-config.js` — 프로젝트 설정값, 컬렉션 이름(`graffiti_posts`), 관리자 이메일(`ADMIN_EMAIL`), 그리고 `IS_PLACEHOLDER_CONFIG` 플래그(`projectId`가 `TEMP_`로 시작하면 실제 Firebase 프로젝트 없이 로컬 개발 모드로 동작). 다른 모든 Firebase 관련 파일이 이 플래그를 참조해 각자 폴백 로직을 중복 구현하지 않도록 함.
- `firebase-app.js` — `getFirebaseApp()` 싱글턴으로 Firestore/Auth가 동일 App 인스턴스를 공유.
- `firebase-client.js` — Firestore CRUD(`fetchPosts`/`createPost`/`updatePost`/`deletePost`). `IS_PLACEHOLDER_CONFIG`일 때는 즉시 `null`/`false`를 반환하고, 실제 연결 시에도 6초 타임아웃(`REQUEST_TIMEOUT_MS`)을 넘기면 실패로 간주해 연결을 `terminate` 후 리셋한다(무한 재시도 방지).
- `firebase-auth.js` — 원장 계정(`ADMIN_EMAIL`) 로그인/로그아웃/로그인 상태 확인.
- `admin-auth.js` — "수정"/"삭제"/"글 작성" 진입 시 뜨는 비밀번호 모달(`requestAdminPassword`)과 삭제 확인 모달(`confirmAction`). `IS_PLACEHOLDER_CONFIG`이면 로컬 하드코딩 비밀번호(`DEV_FALLBACK_PASSWORD`)로, 실제 config가 설정되면 Firebase Authentication으로 자동 전환된다 — 두 경로를 분기하는 지점이 이 파일이다.
- Firestore 보안 규칙은 `firestore.rules`에 있으며, 반드시 `ADMIN_EMAIL`과 규칙 파일 내 이메일이 일치해야 한다. 규칙 파일은 코드에서 자동 배포되지 않고 Firebase 콘솔에 수동으로 붙여넣어 게시해야 함.

## 저장소 관례

- `tasks/*.md` — 작업 지시/요구사항을 기록. `report/YYYY-MM-DD-*.md` — 해당 작업을 완료한 뒤 진행 과정을 날짜별로 정리한 보고서. 새 작업을 마쳤을 때 이 관례를 따라 보고서를 남기는 흐름이 이미 자리잡혀 있다.
- **작업 완료 후 문서 점검(중요 규칙)**: 사용자가 지시한 작업이 끝날 때마다, 별도 요청 없이도 매번 `PRD.md`, `DEV_PLAN.md`, `CLAUDE.md`, `DEVLOG.md`, `ARCHITECTURE.md` 5개 문서를 검토해 업데이트가 필요하면 반영한다.
  - `DEVLOG.md`는 날짜별 작업 일지 — 무슨 작업을 했는지 간단히 기록(장황한 서술 대신 요약).
  - `PRD.md`/`DEV_PLAN.md`는 제품 범위·요구사항이나 기술 계획이 바뀐 경우에만 갱신.
  - `CLAUDE.md`는 개발 명령, 페이지 구조, Firebase 연동, 저장소 관례 등 이 문서가 다루는 내용이 바뀐 경우에만 갱신.
  - `ARCHITECTURE.md`는 서비스 아키텍처(배포 구조, 프론트엔드/백엔드 구성, 서브도메인 연동 상태 등)에 실질적 변화가 있을 때만 갱신 — 작업 과정 자체는 이 문서가 아니라 `report/*.md`에 남긴다.
  - 5개 중 바꿀 내용이 없으면 억지로 손대지 않고 넘어간다.
