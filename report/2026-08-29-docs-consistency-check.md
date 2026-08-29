# 2026-08-29 — 전체 문서 정합성 체크

5개 문서(`CLAUDE.md` + `docs/` 4종)가 주장하는 사실을 코드 실물과 기계적으로 전수 대조했다. 결론부터: **불일치 1건**을 찾아 수정했고, 나머지는 전부 일치했다.

## 체크리스트

- [x] 30개 페이지 공통 요소 전수 대조 (공통 CSS/JS·favicon·OG·로고·`mobile-menu.js`·`pt-16`)
- [x] GNB 브레이크포인트(`lg:`) 및 `md:` 잔존 여부
- [x] 내부 링크(href/src) 무결성 전수 검사
- [x] `index.html` 섹션별 카드 수·클릭 가능 여부
- [x] `ARCHITECTURE.md` §1 기술 스택 표 vs 실제 CDN 라이브러리 버전
- [x] `ARCHITECTURE.md` §6 서브도메인 상태표 vs 실제 GNB 링크
- [x] 문서가 참조하는 저장소 내 파일 경로 실재 여부
- [x] 문서 내부 `§n` 상호참조 유효성
- [x] `DEV_PLAN.md` Phase 상태 vs 실제 파일 상태
- [x] DEVLOG 버전 기록 커버리지 vs git 이력
- [x] 미참조 이미지 확인
- [x] 로컬 서버 응답 확인
- [x] 발견된 불일치 수정 + 문서 반영

## 대조 결과 — 이상 없음

| 항목 | 결과 |
| --- | --- |
| 페이지 수 | 30장 (`index.html` 1 + `src/*.html` 29) — §1 서술과 일치 |
| `/assets/js/tailwind-config.js`·`/assets/css/base.css` 참조 | 30/30 |
| favicon(`?v=1`)·apple-touch-icon | 30/30 |
| OG 태그(`og:title`/`description`/`image`/`image:width`) | 30/30 |
| 헤더 로고 이미지·`mobile-menu.js`·`main pt-16` | 30/30 |
| GNB `hidden lg:inline-flex`·`hidden lg:flex`·`lg:hidden` | 30/30 |
| GNB `md:` 계열 잔존 | 0건 |
| 인라인 `tailwind.config`·`@view-transition` 잔존 | 0건 (공통 파일로 분리 완료) |
| 내부 링크 | 참조 705건 중 깨짐 **0건** |
| 카드 연결 | Language 5 / 정렬·탐색 8 / 자료구조 6 / Web 5 = `<a>` 24장, Unity·Agent AI 8장은 비클릭 `<div>` — `PRD.md` §미착수 서술과 일치 |
| 캐러셀 | `lang-swiper`·`algo-swiper`·`ds-swiper`·`web-swiper` 4개 |
| CDN 라이브러리 버전 | Pretendard v1.3.9 / Swiper 11 / AOS 2.3.1 / Firebase 10.12.2 — §1 표와 **전부 일치** |
| GNB 링크 상태 | wonoj·business·studio 활성, **LMS만 `aria-disabled`+"준비중"** — §6 표와 일치 |
| `CNAME` | `recode.ai.kr` |
| `§n` 상호참조 | §1~§8 존재, 깨진 참조 0건 |
| `DEV_PLAN` Phase | Phase 2 미착수(낙서장 본문 톤), Phase 3 3/4(LMS 잔여) — 실제와 일치 |
| 로컬 서버 | 11개 경로 전부 200 |

### 오탐으로 확인한 것

- `src/mockup.html` 참조(3개 문서) — 2026-08-22에 **삭제된 파일을 이력으로 서술**하는 문장이라 정상.
- `report/*.md`·`report/YYYY-MM-DD-<slug>.md` — 실제 파일이 아니라 **명명 규칙 표기**.
- `src/algo-sort.html` — 다른 페이지에서 링크되지 않음을 확인, "미사용 파일"이라는 문서 서술과 일치.
- `CLAUDE.md` GNB 항목의 페이지 열거 — `src/lang-*.html` 5개, `src/algo-{bubble,...}-sort.html` 5개 같은 축약 표기라 30장을 모두 포괄.
- 미참조 이미지 9개(43MB) — `consult-0{1..4}.png`·`bg-consult.png`는 **크롭 소스로 의도적 보존**, devicon 로고 SVG 4개는 "현재 미참조, 추후 재사용 가능"이라고 이미 문서에 명시됨.

## 발견한 불일치 1건 — 수정 완료

**`docs/ARCHITECTURE.md` §1 기술 스택 표의 폰트 행**

- 기존 서술: `| 폰트 | Pretendard Variable v1.3.9(jsDelivr), JetBrains Mono(코드/라벨용) | 30개 페이지 전부 <link>로 로드 |`
- 실제: `<link>`로 내려받는 웹폰트는 **Pretendard 하나뿐**이다. JetBrains Mono를 로드하는 `<link>`는 30개 페이지 어디에도 없고(0/30), 이름이 등장하는 곳은 `assets/js/tailwind-config.js`의 `mono` 스택(`'"JetBrains Mono"', 'ui-monospace', 'SFMono-Regular', 'monospace'`)과 `algo-bfs.html`/`algo-dfs.html`의 SVG 인라인 `font-family` 두 곳뿐이다.
- 영향: JetBrains Mono가 **설치된 기기에서만** 그 서체로 보이고, 나머지는 `ui-monospace`/`SFMono-Regular`로 폴백된다. 코드 블록·mono 라벨의 실제 서체가 기기마다 달라진다.
- 조치: 표를 실제 동작대로 고쳤다(폰트 로드 = Pretendard, `font-mono`는 폴백 스택임을 명시).

**남은 판단은 사용자 몫** — 지금처럼 시스템 모노스페이스 폴백을 유지할지, JetBrains Mono도 `<link>`로 로드해 기기 간 서체를 통일할지. 후자를 택하면 30개 페이지에 `<link>` 한 줄씩 추가하는 작업이 된다(폰트 하나가 늘어나는 만큼 로딩 비용도 함께 증가).

## 개선 여지 — DEVLOG 버전 기록 커버리지

git 커밋 52개(v0.01~v0.52) 중 **24개 버전이 `DEVLOG.md`에 버전 문자열로 등장하지 않는다**: v0.01\~v0.09, v0.11\~v0.14, v0.19, v0.21\~v0.23, v0.25\~v0.29, v0.51.

다만 **작업 내용 자체가 빠진 것은 아니다** — DEVLOG는 날짜별 일지라 해당 작업(낙서장 게시판, GNB 공통화, 자료구조 6종, Web 코스 5종 등)은 모두 날짜 항목으로 기록돼 있고, `vX.XX` 표기만 없다. 2026-08-28 점검(v0.50)에서 v0.35·v0.39\~v0.48을 같은 방식으로 보완한 전례가 있으므로, 초기 구간도 동일하게 보완할 수 있다.

이번에는 오늘 작업분(v0.52·v0.53)에만 버전 표기를 붙였다. 나머지 22건 소급 보완은 지시가 있을 때 진행한다.

## 검증 결과

- 수정 후 `docs/ARCHITECTURE.md` 폰트 행이 실제 로드 상태와 일치함을 확인.
- 사이트 산출물(HTML/CSS/JS/이미지) 변경 없음 — 배포 영향 없음.
