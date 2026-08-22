# DEV_PLAN.md — 개발 계획

`PRD.md`의 범위를 어떻게 구현할지에 대한 기술적 계획. 상세 요구사항은 `PRD.md`, 철학적 배경은 `NEED.md` 참고.

## 1. 기술 스택
- **유지**: 빌드 도구 없는 정적 HTML, Tailwind CDN, Vanilla JS ES Module. 페이지 규모(5~7개) 대비 빌드 파이프라인 도입은 과함 — GitHub Pages 루트 배포와의 궁합도 그대로 유지.
  - Tailwind CDN 런타임 방식의 알려진 트레이드오프: 스크립트가 로드·실행되기 전까지 유틸리티 클래스가 전혀 적용되지 않아 페이지 이동마다 짧은 FOUC(특히 `fixed` GNB가 접히는 흔들림)가 생긴다(2026-08-22 발견, 같은 날 해결 확인). 빌드 도구 없이 이 문제를 완화하기 위해, 헤더/`main` 레이아웃만 Tailwind와 무관한 순수 CSS로 Tailwind `<script>`보다 앞에 critical 스타일을 추가하고, 정적 다중 페이지 특유의 새로고침/전환 끊김에는 CSS View Transitions(`@view-transition { navigation: auto; }`)를 추가 — 사용자가 하드 리프레시로 최종 확인함(상세: `../CLAUDE.md` GNB 항목, `DEVLOG.md`). 근본적으로 FOUC 자체를 없애려면 정적 컴파일(빌드 도구 도입)이 필요하지만, 위 대응으로 체감 가능한 흔들림은 해소됨 — 페이지 수가 크게 늘어나 다시 부담되면 그때 빌드 도구 도입을 재검토.
- **신규 도입**: Swiper(캐러셀)와 AOS(스크롤 진입 애니메이션) — 둘 다 `mockup.html`에서 시안으로 검증한 뒤 `index.html`에 그대로 채택(2026-08-22). GSAP은 애초 계획에 있었으나 Swiper와의 타이밍 이슈·무게 때문에 AOS로 대체하기로 확정, 도입하지 않음.
- **디자인 도구**: `design` 스킬(Artifact 캔버스)로 목업 스케치. Figma MCP는 `figma@claude-plugins-official` 플러그인(project scope, `.claude/settings.json`의 `enabledPlugins`로 관리 — git 동기화됨)으로 연결 완료(2026-08-21), 인증도 완료된 상태.
- **파일 구조 (2026-08-22 확정)**: 페이지 수가 늘어나며(`lang-*.html` 등) 루트가 복잡해져 `index.html`만 저장소 루트에 남기고 나머지 `.html`은 `src/`로 이동. GitHub Pages branch 배포가 `/ (root)` 또는 `/docs`만 지원해 `/src`를 배포 소스로 쓸 수 없으므로, 루트 배포 진입점(`index.html`)은 그대로 두고 나머지만 폴더로 정리하는 절충안을 택함. 새 페이지는 `src/`에 추가하고, 루트 ↔ `src/` 간 링크에는 `../`를 붙인다(상세: `../CLAUDE.md` "페이지 구조").

## 2. 브랜치 전략
- `dev` 브랜치에서 작업 → 로컬 서버(`python3 -m http.server 8765`)로 확인 → (평소에는) `main`으로 merge → GitHub Pages 자동 배포.
- **`index.html` 리뉴얼 작업 중에는 `main` 병합 보류(2026-08-21 확정, 2026-08-22 해제)**: 리뉴얼 기간 동안 `index.html`을 직접 건드리는 작업이라 `dev`에서만 커밋을 쌓았다. Phase 1(§3) 콘텐츠 완료 후 사용자가 명시적으로 지시해 `dev`(v0.20, 커밋 `2623db0`)를 `main`에 fast-forward 병합·push 완료(2026-08-22) — GitHub Pages가 재배포되어 `recode.ai.kr`에 실제 반영됨. 이 병합 보류 방침은 이 시점부로 해제되었고, 이후로는 일반적인 브랜치 전략(위 문단)을 따른다 — 다만 실서비스에 영향을 주는 병합/배포는 항상 사용자의 명시적 지시가 있을 때 진행한다.

## 3. 단계별 계획

### Phase 0 — 기획 (현재 단계)
- `PRD.md`, `DEV_PLAN.md` 작성.
- `design` 스킬로 `index.html` 허브 목업 스케치.

### Phase 1 — `index.html` 허브 재설계 (완료, 2026-08-22)
- 5갈래 내비게이션 구조 반영 (OJ/낙서장/LMS/프로젝트 의뢰/오프라인 문의) — 완료.
- 히어로·철학 섹션 재작성: 애초 계획은 `NEED.md`의 3대 기둥 구조를 텍스트 중심 히어로로 재작성하는 방향이었으나, 실제로는 `mockup.html`에서 검증한 "코스 카테고리 히어로(Language/Algorithm/Web & WebApp/Unity/Agent AI 자동 전환 배너) + 압축된 핵심 철학 섹션 + CTA" 구성을 최종안으로 채택. `mockup.html` 내용을 `index.html`로 옮기고 `mockup.html`은 삭제(상세: `../report/2026-08-22-index-adopt-mockup.md`).
- Swiper(캐러셀)/AOS(스크롤 애니메이션) 적용 완료, GSAP은 채택하지 않음.

### Phase 2 — 낙서장 톤 조정
- `graffiti*.html`의 디자인 톤을 새 브랜드 톤에 맞춰 조정 (Firestore CRUD 로직은 변경하지 않음).
- 헤더는 2026-08-22 GNB 통일 작업으로 선반영 완료 — `index.html`과 완전히 동일한 마크업으로 교체(페이지별 커스텀 nav 제거). 포지셔닝은 같은 날 `fixed`→`sticky`→다시 `fixed`로 두 번 전환(스크롤 당길 때 오버스크롤 바운스에 흔들리지 않도록 `fixed`로 최종 확정, `<main>`에 `pt-16` 오프셋 필요). 본문(카드 리스트·푸터 등)의 톤 조정은 아직 남은 작업.

### Phase 2.5 — 언어별 코스 상세 페이지 (`lang-*.html`) (완료, 2026-08-22)
- `index.html` Language 카드 클릭 시 이동하는 개별 언어 페이지(과거에는 `mockup.html`의 카드였으나, `mockup.html`이 `index.html`로 흡수되며 이제 `index.html`의 카드). 커리큘럼 목록 UI는 korea-pass.kr 공지사항 목록 페이지(`/notice/noticeList.do`)를 벤치마크(브레드크럼+타이틀 + 언어 바로가기 탭 + 뱃지·메타·제목 카드 리스트) — 검색창과 "더보기" 페이지네이션은 이후 제거되어 12개 카드를 처음부터 전부 노출.
- `src/lang-cp.html`(C/C++)을 템플릿으로 `src/lang-jv.html`(Java)/`src/lang-py.html`(Python)/`src/lang-js.html`(JavaScript)/`src/lang-dt.html`(Dart)까지 5개 페이지 전부 제작 완료. 각 페이지 상단 언어 바로가기 탭(5개 pill 링크)과 `index.html` Language 카드에서 상호 연결됨.

### Phase 3 — 외부 연동 정리
- OJ(`oj.recode.ai.kr`)/LMS(`lms.recode.ai.kr`)/business(`business.recode.ai.kr`)/studio(`studio.recode.ai.kr`) 4개 서브도메인은 각각 별도 프로젝트로 직접 제작 중 — 이 저장소는 오픈 시점에 맞춰 링크 활성화·"준비중" 배지 정리만 담당.

## 4. 작업 관례
- 각 Phase 착수 시 `../tasks/*.md`에 작업 지시 기록, 완료 후 `../report/YYYY-MM-DD-*.md`에 진행 보고서 작성 (기존 관례 유지).
