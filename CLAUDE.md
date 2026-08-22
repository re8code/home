# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 개요

"Recode Coding" 홈페이지 — 빌드 도구/패키지 매니저 없는 순수 정적 사이트(HTML + Tailwind CDN + Vanilla JS ES Module). `index.html`만 저장소 루트에 있어 GitHub Pages 루트 배포와 그대로 호환되고, 나머지 페이지는 모두 `src/`에 있다(2026-08-22, 아래 "페이지 구조" 참고).

## 개발 명령

- **로컬 서버 실행**: `python3 -m http.server 8765` (저장소 루트에서 실행 후 `http://localhost:8765/index.html` 접속, 그 외 페이지는 `http://localhost:8765/src/graffiti.html`처럼 `src/` 경로로 접속). Firestore(`assets/js/firebase-client.js`)를 사용하는 `src/graffiti*.html`은 `file://`로 직접 열면 ES module import가 동작하지 않으므로 반드시 로컬 서버를 통해 확인해야 한다.
- **빌드/린트/테스트**: 없음. `package.json` 자체가 존재하지 않는다. 변경 확인은 브라우저에서 직접 페이지를 열어 눈으로 검증한다(가능하면 claude-in-chrome으로 중간 점검).

## 배포

- GitHub Pages, `main` 브랜치 `/ (root)` 소스로 배포(GitHub Pages branch 배포는 `/ (root)` 또는 `/docs`만 지원 — `/src`는 소스로 지정 불가). 커스텀 도메인은 저장소 루트의 `CNAME` 파일(`recode.ai.kr`)로 연결됨 — 이 파일을 삭제하거나 내용을 바꾸면 도메인 연결이 끊어지므로 주의.
- `index.html`만 루트에 남기고 나머지 페이지를 `src/`로 옮긴 것(2026-08-22)도 이 제약 때문 — 루트 배포 진입점(`index.html`)은 유지하면서 나머지 `.html`은 폴더로 정리했다.
- 자세한 절차/DNS 설정은 `report/2026-07-29-deployment-guide.md` 참고.

## 페이지 구조

`index.html`만 저장소 루트에 있고, 나머지 `.html` 페이지는 전부 `src/`에 있다(2026-08-22 정리). GitHub Pages branch 배포는 소스 폴더로 `/ (root)` 또는 `/docs`만 지원해 `/src`를 그대로 배포 소스로 지정할 수 없기 때문에, `index.html`을 루트에 남겨 배포 진입점을 유지하고 나머지 페이지만 `src/`로 옮겼다. 공유 컴포넌트나 템플릿 시스템은 없다 — Tailwind 설정(브랜드 색상 `brand.50~950`, Pretendard 폰트 등)이 `<script>tailwind.config = {...}</script>` 블록으로 **페이지마다 중복 정의**되어 있다. 톤/색상을 바꿀 때는 모든 페이지 상단의 config 블록을 동일하게 맞춰야 한다.

- `index.html` (루트) — 랜딩 페이지. Epic Games Store 레이아웃 참고 히어로(5개 훈련 코스 카테고리 자동 전환 배너 + 사이드 게이지 리스트) + Language/Algorithm/Web & WebApp/Unity/Agent AI 5개 코스 섹션 + 핵심 철학 + 1:1 상담 CTA로 구성. 원래 `src/mockup.html`이라는 별도 파일에서 라이트 톤 시안으로 반복 검토하다가, 2026-08-22 최종안을 이 파일로 옮기고 `mockup.html`은 삭제했다(그 전 다크 톤 버전의 문제의식/훈련 프로세스/대상 섹션은 이 교체로 사라짐 — 상세: `report/2026-08-22-index-adopt-mockup.md`). Swiper(캐러셀)와 AOS(스크롤 애니메이션)를 CDN으로 추가 로드하는 유일한 페이지. `src/` 페이지로의 링크는 `src/graffiti.html`처럼 `src/` 접두사를 붙인다.
- `src/graffiti.html` / `src/graffiti-detail.html` / `src/graffiti-new.html` — "원장님의 낙서" 게시판 (목록 / 상세·수정·삭제 / 작성). Firestore CRUD를 `assets/js/firebase-client.js`에서 가져와 사용하며, `<script type="module">` 인라인 블록에서 DOM과 연결한다. 헤더는 `index.html`과 동일한 GNB(아래 참고)를 쓰지만, 본문(카드 리스트·푸터 등)의 디자인 톤 조정은 아직 미착수(`doc/DEV_PLAN.md` Phase 2).
- `src/lang-cp.html` — Language 코스 중 C/C++ 상세 페이지(`index.html`의 C/C++ 카드에서 연결). 커리큘럼 목록 UI는 korea-pass.kr 공지사항 목록 페이지(`/notice/noticeList.do`)를 벤치마크(브레드크럼(홈/C/C++, "훈련 코스" 중간 항목은 2026-08-22 제거)+타이틀, 뱃지+메타+제목 카드 리스트, "더보기" 버튼 — 검색창은 2026-08-22 제거). 상단 "LANGUAGE" 라벨은 번호(`01 ·`) 없이 텍스트만 표기(2026-08-22). `index.html`과 동일한 라이트 테마·헤더/푸터를 재사용.
  - **언어 바로가기 탭** (2026-08-22, 이전엔 기초/실습/프로젝트 카테고리 필터였음): C/C++/Java/Python/JavaScript/Dart 5개 pill 탭이 각각 `lang-cp.html`/`lang-jv.html`/`lang-py.html`/`lang-js.html`/`lang-dt.html`로 이동하는 페이지 전환 링크로 동작(현재 페이지는 `aria-current="page"` + `is-active` 스타일). 5개 파일 모두 존재하며(2026-08-22, C/C++·Java·Python·JavaScript·Dart 전부 제작 완료) 서로의 탭 `href`가 정확히 일치한다. 새 언어 페이지를 추가로 만들 때는 이 파일명 규칙을 따르고, **5개 페이지 전부**의 언어 바로가기 탭에 새 항목을 반영해야 한다(한 파일만 만들고 나머지 4개의 탭을 안 챙기면 링크가 어긋난다).
  - "더보기" 페이지네이션은 2026-08-22 제거 — 12개 커리큘럼 카드를 처음부터 전부 노출한다(관련 JS도 제거, 정적 마크업만 남음).
- **GNB(전역 내비게이션)**: 2026-08-22부터 헤더(`<header>...</header>` 전체, 로고+nav+CTA+모바일 메뉴)는 9개 페이지(`index.html`, `src/graffiti*.html` 3개, `src/lang-*.html` 5개) 전부 **완전히 동일한 마크업**을 쓴다 — 페이지별 커스텀 nav 링크(예: 예전 `graffiti*.html`의 "철학"/"훈련 코스", `lang-cp.html`의 "훈련 코스")는 제거하고, `index.html`의 GNB(원장님의 낙서/wonoj/LMS·business·studio 준비중/1:1 상담 신청)로 통일했다. 새 페이지를 추가할 때는 이 헤더 블록을 그대로 복사하고 로고·"원장님의 낙서" 링크의 상대경로만 위치에 맞게 조정한다(`src/` 페이지는 로고 `../index.html`, "원장님의 낙서" `graffiti.html`; 루트 `index.html`은 로고 `#`, "원장님의 낙서" `src/graffiti.html`).
  - 헤더 포지셔닝은 `fixed top-0 inset-x-0`(2026-08-22 `sticky`에서 전환 — 스크롤을 당길 때 오버스크롤 바운스로 흔들리지 않도록 완전히 뷰포트에 고정). `fixed`는 문서 흐름에서 빠지므로 모든 페이지의 `<main>`에 `pt-16`(헤더 높이 `h-16`=64px과 동일)을 반드시 함께 줘야 본문이 헤더에 가려지지 않는다 — 새 페이지를 만들 때 이 둘은 항상 짝으로 다닌다.
  - **페이지 이동/새로고침 시 GNB가 순간적으로 흔들리는 문제**(2026-08-22 발견·수정, 1차 대응으로 재현되어 2차로 강화): Tailwind를 CDN 런타임 스크립트(`<script src="https://cdn.tailwindcss.com">`)로 쓰기 때문에, 그 스크립트가 로드·실행되기 전까지는 `header`의 Tailwind 유틸리티 클래스가 전혀 적용되지 않는다. 1차 대응(헤더 `position:fixed`+`height`+`main` 여백만 순수 CSS로 고정)은 헤더 박스 자체가 늘어졌다 접히는 큰 흔들림은 없앴지만, 안의 nav 링크(파란 밑줄 기본 브라우저 스타일)·CTA 버튼(모양 없는 텍스트 → 초록 알약 버튼)·로고 배지·모바일 메뉴 버튼이 Tailwind 로드 전후로 색상·모양이 바뀌는 잔여 깜빡임이 남아 있었음(테스트 방법: Tailwind 스크립트를 `setTimeout`으로 인위적으로 수 초 지연시키는 스크래치 사본을 만들어 로드 전/중/후를 각각 스크린샷 비교 — 이 저장소엔 남기지 않음, 필요시 같은 방식으로 재현 가능).
  - 2차 대응(critical CSS 확장): Tailwind `<script>` 앞의 `<style>` 블록에 헤더 안 요소들의 **최종 렌더링과 동일한 값**을 순수 CSS로 추가 — `header a{color:#fff;text-decoration:none}`(밑줄 제거), `header nav a{color:#94a3b8}`(비활성 링크 회색), `header nav + a{...초록 알약 버튼 스타일...}`(CTA), `header span.rounded-lg{...로고 배지 스타일...}`, `@media (min-width:768px){header #mobile-menu-btn{display:none}}`(데스크톱 폭에서 모바일 버튼 숨김, Tailwind의 `md:hidden`과 동일 breakpoint). 값을 Tailwind가 나중에 생성할 유틸리티와 동일하게 맞췄기 때문에 Tailwind 로드 후에도 재적용만 될 뿐 시각적으로 아무 변화가 없다(멱등) — 지연 테스트로 로드 전/후 스크린샷이 완전히 동일함을 확인.
  - 새 페이지를 만들 때 이 critical CSS 블록 전체(`header`/`header > div:first-child`/`header nav`/`header #mobile-menu`/`header a`/`header nav a`/`header nav + a`/`header span.rounded-lg`/미디어쿼리/`main`)를 헤더 마크업과 함께 그대로 복사할 것 — 하나라도 빠지면 그 요소만 다시 깜빡인다.
  - 2차 대응 후에도 사용자가 흔들림을 재보고해, `PerformanceObserver({type:'layout-shift'})`로 실제 새로고침을 측정 — **레이아웃 시프트 0건**으로 확인됨(콘텐츠가 움직이는 종류의 흔들림은 더 이상 없음). 그래도 남아있다면 그건 시프트가 아니라 정적 다중 페이지 사이트가 새로고침/이동마다 이전 문서를 통째로 버리고 새로 그리는 **MPA 전환 자체의 끊김**일 가능성이 큼 — 이건 헤더 CSS로 고칠 수 없어서, CSS Cross-Document View Transitions(`@view-transition { navigation: auto; }`, critical `<style>` 블록 맨 앞)를 추가해 같은 오리진 페이지 전환을 브라우저가 자동 크로스페이드하도록 함(Chrome/Edge 126+, 빌드 도구 불필요, 미지원 브라우저는 그냥 무시 — progressive enhancement). 새 페이지를 만들 때 이 한 줄도 critical CSS와 함께 복사할 것. **사용자가 하드 리프레시로 재확인해 최종적으로 흔들림 해결 확인됨(2026-08-22)** — 상세 진단 과정은 `doc/DEVLOG.md` 참고.
- 경로 규칙: `src/` 안의 페이지끼리는 같은 디렉터리이므로 파일명만으로 링크(`href="graffiti.html"` 등)하고, 루트(`index.html`)나 `assets/`를 가리킬 때는 반드시 `../`를 붙인다(`href="../index.html"`, `src="../assets/js/mobile-menu.js"`). `assets/js/*.js` 파일끼리의 상호 import(`from './firebase-config.js'` 등)는 위치가 바뀌지 않았으므로 그대로 둔다.
- 모든 페이지 하단에서 `assets/js/mobile-menu.js`(루트에서 상대경로, `src/` 페이지는 `../assets/js/mobile-menu.js`)를 `defer`로 로드해 모바일 내비게이션 토글(`#mobile-menu-btn` / `#mobile-menu`)을 처리한다.
- `assets/image/` — 외부에서 가져온 로고·아이콘 등 이미지 리소스(예: `index.html` Language 카드의 언어별 로고 PNG). 각 파일의 출처·라이선스는 도입 시점의 `report/*.md`에 기록되어 있으니, 재배포 범위를 확인하려면 해당 보고서를 참고한다.

## Firebase 연동 (`assets/js/`)

"원장님의 낙서" 게시판 전용. 파일별 역할:

- `firebase-config.js` — 프로젝트 설정값, 컬렉션 이름(`graffiti_posts`), 관리자 이메일(`ADMIN_EMAIL`), 그리고 `IS_PLACEHOLDER_CONFIG` 플래그(`projectId`가 `TEMP_`로 시작하면 실제 Firebase 프로젝트 없이 로컬 개발 모드로 동작). 다른 모든 Firebase 관련 파일이 이 플래그를 참조해 각자 폴백 로직을 중복 구현하지 않도록 함.
- `firebase-app.js` — `getFirebaseApp()` 싱글턴으로 Firestore/Auth가 동일 App 인스턴스를 공유.
- `firebase-client.js` — Firestore CRUD(`fetchPosts`/`createPost`/`updatePost`/`deletePost`). `IS_PLACEHOLDER_CONFIG`일 때는 즉시 `null`/`false`를 반환하고, 실제 연결 시에도 6초 타임아웃(`REQUEST_TIMEOUT_MS`)을 넘기면 실패로 간주해 연결을 `terminate` 후 리셋한다(무한 재시도 방지).
- `firebase-auth.js` — 원장 계정(`ADMIN_EMAIL`) 로그인/로그아웃/로그인 상태 확인.
- `admin-auth.js` — "수정"/"삭제"/"글 작성" 진입 시 뜨는 비밀번호 모달(`requestAdminPassword`)과 삭제 확인 모달(`confirmAction`). `IS_PLACEHOLDER_CONFIG`이면 로컬 하드코딩 비밀번호(`DEV_FALLBACK_PASSWORD`)로, 실제 config가 설정되면 Firebase Authentication으로 자동 전환된다 — 두 경로를 분기하는 지점이 이 파일이다.
- Firestore 보안 규칙은 `firestore.rules`에 있으며, 반드시 `ADMIN_EMAIL`과 규칙 파일 내 이메일이 일치해야 한다. 규칙 파일은 코드에서 자동 배포되지 않고 Firebase 콘솔에 수동으로 붙여넣어 게시해야 함.

## 저장소 관례

- `doc/` — `PRD.md`/`DEV_PLAN.md`/`DEVLOG.md`/`ARCHITECTURE.md` 4개 주요 문서가 위치한 폴더(2026-08-22 정리). `CLAUDE.md`만 Claude Code가 저장소 루트에서 자동으로 읽는 파일이라 루트에 남아 있다 — 4개 문서를 가리킬 때는 `doc/PRD.md`처럼 `doc/` 접두사를 붙인다.
- `tasks/*.md` — 작업 지시/요구사항을 기록. `report/YYYY-MM-DD-*.md` — 해당 작업을 완료한 뒤 진행 과정을 날짜별로 정리한 보고서. 새 작업을 마쳤을 때 이 관례를 따라 보고서를 남기는 흐름이 이미 자리잡혀 있다.
- **작업 완료 후 문서 점검(중요 규칙)**: 사용자가 지시한 작업이 끝날 때마다, 별도 요청 없이도 매번 `doc/PRD.md`, `doc/DEV_PLAN.md`, `CLAUDE.md`, `doc/DEVLOG.md`, `doc/ARCHITECTURE.md` 5개 문서를 검토해 업데이트가 필요하면 반영한다.
  - `doc/DEVLOG.md`는 날짜별 작업 일지 — 무슨 작업을 했는지 간단히 기록(장황한 서술 대신 요약).
  - `doc/PRD.md`/`doc/DEV_PLAN.md`는 제품 범위·요구사항이나 기술 계획이 바뀐 경우에만 갱신.
  - `CLAUDE.md`는 개발 명령, 페이지 구조, Firebase 연동, 저장소 관례 등 이 문서가 다루는 내용이 바뀐 경우에만 갱신.
  - `doc/ARCHITECTURE.md`는 서비스 아키텍처(배포 구조, 프론트엔드/백엔드 구성, 서브도메인 연동 상태 등)에 실질적 변화가 있을 때만 갱신 — 작업 과정 자체는 이 문서가 아니라 `report/*.md`에 남긴다.
  - 5개 중 바꿀 내용이 없으면 억지로 손대지 않고 넘어간다.
