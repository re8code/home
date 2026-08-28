# 2026-08-28 — 장비 이동 후 전체 문서 점검

새 장비(`/Users/Wons/recode-ai/home`)에서 `main`을 pull한 뒤, 저장소 전체를 다시 파악하고 5개 문서(`CLAUDE.md` + `docs/` 4종)를 코드 실물과 대조 점검했다. 점검 도중 사용자가 `CLAUDE.md`에 새 규칙 4종(제1원칙 / git commit 규칙 / 여러 장비 간 작업 연속성 / 작업 보고서)을 추가해, 그 규칙까지 반영해 마무리했다.

## 체크리스트

- [x] 저장소 구조·git 이력·브랜치 상태 파악 (`main` = v0.48, 원격 `dev` = v0.49)
- [x] `docs/PRD.md` / `docs/DEV_PLAN.md` / `docs/ARCHITECTURE.md` / `docs/DEVLOG.md` / `CLAUDE.md` 정독
- [x] `tasks/*.md`, `report/task & bug/*.md` 미완 항목 확인 (전부 `[x]`)
- [x] 30개 페이지 공통 요소 전수 대조 (공통 CSS/JS·favicon·OG·로고·GNB 브레이크포인트·`pt-16`)
- [x] 내부 링크(href/src) 무결성 전수 검사
- [x] 랜딩 카드 연결 상태 및 미사용 파일·미참조 이미지 확인
- [x] 로컬 서버 기동 후 주요 경로 응답 확인
- [x] 발견된 문서 불일치 수정 (`PRD`/`DEV_PLAN`/`ARCHITECTURE`/`DEVLOG`)
- [x] 사용자가 수정한 `CLAUDE.md` 신규 규칙 확인 및 반영(`ARCHITECTURE.md` 상단 기술 스택 절 신설, 이 보고서 작성)

## 코드 대조 결과 — 이상 없음

| 항목 | 결과 |
| --- | --- |
| `/assets/js/tailwind-config.js`·`/assets/css/base.css` 참조 | 30/30 |
| favicon(`?v=1`)·apple-touch-icon | 30/30 |
| Open Graph 7종 + `og:image:width/height`, `og-image.png` | 30/30 |
| 헤더 로고 이미지(`logo.png`)·`mobile-menu.js` | 30/30 |
| GNB `lg:` 브레이크포인트 클래스·`main pt-16` | 30/30 |
| 인라인 `tailwind.config` / `md:` GNB 클래스 잔존 | 0건 |
| 내부 링크 깨짐 | 0건 (30개 페이지 전수) |
| 카드 연결 | Language 5 / 정렬·탐색 8 / 자료구조 6 / Web 5 = 24장 전부 `<a>`, Unity·Agent AI 8장은 비클릭 `<div>`(미착수) |
| 로컬 서버 응답 | `/`, `/index.html`, `/assets/css/base.css`, `/assets/js/tailwind-config.js`, `/src/about.html`, `/src/algo-bst.html`, `/assets/image/og-image.png` 전부 200 |

저장소 경로가 바뀌었지만 절대경로 하드코딩이 없어(HTML/CSS/JS는 상대경로 또는 `/assets/...`, `start.sh`는 `BASH_SOURCE` 기준) 이동으로 깨진 곳은 없다.

## 문서 수정 내역

### `docs/PRD.md`
- 존재하지 않는 `NEED.md` 참조 2곳 → `../tasks/Philosophy.md`로 정정(v0.13에서 이름·위치가 바뀐 뒤 참조만 남아 있었음).
- In Scope 표가 `index.html`/낙서장/Language 3행에서 멈춰 있어 **Algorithm 코스 14종 / Web & WebApp 5종 / 회사 소개 / Unity·Agent AI(미착수)** 4행 추가.
- 낙서장 상태를 "톤 조정" → "헤더는 통일 완료, 본문 톤 조정 미착수"로 명확화.
- §7이 `DEV_PLAN.md`에 위임했던 "Tailwind config 공통화 여부"의 결정 결과(2026-08-26 공통화) 기록.
- §8에 서브도메인 진행 상황(studio 08-25, business 08-26 활성화 / 준비중은 LMS만) 추가.

### `docs/DEV_PLAN.md`
- 같은 `NEED.md` 참조 2곳 정정.
- §1에 **공통 자산 분리 결정이 아예 누락**돼 있어 신설(PRD §7이 위임한 결정), "페이지 5~7개" → 30개로 현행화.
- Phase 0 "(현재 단계)" → "(완료)", Phase 2에 "(미착수 — 헤더만 선반영)", Phase 2.6 "(착수)" → "(파일럿 완료, 8/8)".
- Phase 3을 "3/4 완료, LMS만 잔여"로 갱신하고 활성화 절차를 명시.

### `docs/ARCHITECTURE.md`
- **§1 "기술 스택" 절 신설**(`CLAUDE.md` 제1원칙의 새 규칙) — 마크업/스타일/폰트/스크립트/UI 라이브러리/백엔드/호스팅/로컬 개발 8행 표. 기존 §1~§6은 §2~§7로 번호를 밀고 내부 상호참조도 함께 조정. §7 갱신 원칙에 "기술 스택은 §1에 유지" 규칙 추가.
- 최종 갱신일 갱신, mermaid 다이어그램에 `algo-*`/`web-*`/`about` 노드 추가.
- `index.html` 행의 "자료구조 6카드는 준비중", `algo-stack.html` 행의 "나머지 5종 준비중" 등 이미 완료된 내용을 가리키던 낡은 서술 정정 + 2026-08-24 Swiper 통일·`watchOverflow` 반영.
- `about.html` 행을 현재 구성(배너 → 중앙 타이틀 → 이미지·텍스트 레이어 4종 → Footer, CTA `mt-auto self-end` flow 배치, "성장시킵니다" 카피)으로 갱신.
- GNB 항목에 로고 이미지 교체·`lg` 브레이크포인트 상향·"준비중은 LMS만" 반영, `assets/image/` 설명 현행화, 전 페이지 공통 `<head>` 요소 항목 신설.

### `docs/DEVLOG.md`
- **`## 2026-08-24` 섹션 헤딩이 통째로 빠져** v0.30~v0.38 작업이 08-23 아래에 섞여 있던 것을 분리.
- 누락된 커밋 기록 보완(v0.35, v0.39~v0.42, v0.43~v0.48).
- 2026-08-28 점검 기록 추가.

## 남은 이슈

1. **`dev`가 `main`보다 1커밋 앞섬** — v0.49(`55001df`, 저장소 경로 이동 기록, 문서만). 사이트 산출물 변경이 없어 배포 영향은 없으나 병합은 사용자 지시 대기.
2. **보고서 공백 구간** — `report/`의 마지막 파일이 2026-08-23이라 v0.30~v0.49(회사 소개 확장, 모바일 버그 6건, studio·business 활성화, 공통 자산 분리, 로고·OG, GNB 브레이크포인트)에 대한 보고서가 없다. 상세 경위는 `docs/DEVLOG.md`에 남아 있으므로 소급 작성은 하지 않았다 — 이후 작업부터 이 관례를 유지한다.
3. **미참조 원본 이미지** — `assets/image/`의 `bg-consult.png`·`consult-0{1..4}.png` 5장(~42MB)이 어느 페이지에서도 참조되지 않는다. 재크롭 소스로 보존 중이며, 이미 git 이력에 포함돼 지금 삭제해도 클론 용량은 줄지 않는다.
4. **미착수 범위** — Unity·Agent AI 코스 상세 페이지, 낙서장 본문 톤 조정(Phase 2), LMS 링크 활성화, `src/algo-sort.html` 재사용 여부.
