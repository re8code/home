# DEV_PLAN.md — 개발 계획

`PRD.md`의 범위를 어떻게 구현할지에 대한 기술적 계획. 상세 요구사항은 `PRD.md`, 철학적 배경은 `NEED.md` 참고.

## 1. 기술 스택
- **유지**: 빌드 도구 없는 정적 HTML, Tailwind CDN, Vanilla JS ES Module. 페이지 규모(5~7개) 대비 빌드 파이프라인 도입은 과함 — GitHub Pages 루트 배포와의 궁합도 그대로 유지.
- **신규 도입**: Swiper(캐러셀, `mockup.html`에서 이미 실험함), AOS(스크롤 진입 애니메이션, 역시 `mockup.html`에서 실험함), GSAP(추가 인터랙션 강화용, 신규 도입).
- **디자인 도구**: 지금은 `design` 스킬(Artifact 캔버스)로 목업 스케치. Figma MCP는 추후 적절한 시점에 연결해 효율성·정밀도를 높일 예정(현재 등록된 MCP 서버들은 모두 삭제 대상이므로 무시).

## 2. 브랜치 전략
- `dev` 브랜치에서 작업 → 로컬 서버(`python3 -m http.server 8765`)로 확인 → `main`으로 merge → GitHub Pages 자동 배포.
- 현재 로컬 `dev`에 `origin/dev` 대비 미푸시 커밋(v0.10)이 있고, 여러 미커밋 변경사항(설정 정리, `CLAUDE.md`/`NEED.md`/`PRD.md` 등)이 있음 — 리뉴얼 착수 전 별도로 정리 필요.

## 3. 단계별 계획

### Phase 0 — 기획 (현재 단계)
- `PRD.md`, `DEV_PLAN.md` 작성.
- `design` 스킬로 `index.html` 허브 목업 스케치.

### Phase 1 — `index.html` 허브 재설계
- 5갈래 내비게이션 구조 반영 (OJ/낙서장/LMS/프로젝트 의뢰/오프라인 문의).
- 히어로·철학 섹션 재작성 (`NEED.md`의 3대 기둥 구조 기반).
- Swiper/AOS/GSAP 적용.

### Phase 2 — 신규 페이지 제작
- 프로젝트 의뢰 접수 페이지.
- 오프라인 수업 문의 페이지.
- 폼 데이터 처리 방식은 `PRD.md` 미결 사항 확정 후 결정 (기존 Firestore 패턴 재사용 유력).

### Phase 3 — 낙서장 톤 조정
- `graffiti*.html`의 디자인 톤을 새 브랜드 톤에 맞춰 조정 (Firestore CRUD 로직은 변경하지 않음).

### Phase 4 — 외부 연동 정리
- OJ(`oj.recode.ai.kr`)/LMS(`lms.recode.ai.kr`) 서브도메인 오픈 시점에 맞춰 링크 활성화·"준비중" 배지 정리.

## 4. 작업 관례
- 각 Phase 착수 시 `tasks/*.md`에 작업 지시 기록, 완료 후 `report/YYYY-MM-DD-*.md`에 진행 보고서 작성 (기존 관례 유지).
