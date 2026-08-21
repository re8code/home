# DEVLOG.md — 작업 일지

## 2026-08-21
- Figma MCP 서버를 project scope로 등록.
  - 처음엔 `.mcp.json`에 직접 `figma` 서버(`https://mcp.figma.com/mcp`)를 추가했으나, 이미 `figma@claude-plugins-official` 플러그인(user scope, MCP 서버 + `figma-use` 등 스킬 12개 포함)이 설치되어 있어 중복 확인됨.
  - 논의 후 플러그인을 유지하되 scope만 user → project로 변경하기로 결정: `claude plugin uninstall figma` → `claude plugin install figma@claude-plugins-official --scope project`. `.claude/settings.json`의 `enabledPlugins`에 등록되어 git으로 팀과 동기화됨.
  - 수동으로 추가했던 `.mcp.json`의 `figma` 항목은 중복이라 제거(빈 파일도 삭제).
  - `claude mcp login plugin:figma:figma`로 OAuth 인증 완료, `claude mcp list` 기준 `✔ Connected` 확인.
- "작업 완료 후 PRD.md/DEV_PLAN.md/CLAUDE.md/DEVLOG.md 4개 문서 점검" 규칙을 `CLAUDE.md`의 "저장소 관례" 섹션에 명문화.
- `tasks/Philosophy.md` 핵심 지향점에 "최종 목적: 대학생 코딩 컨설팅(코딩 수업뿐 아니라 대학 생활 전반을 아우름)" 보완.
- `tasks/needs.md` 검토 후 `PRD.md`/`DEV_PLAN.md` Scope 정리: oj/lms/business/studio 4개 사이트 모두 별도 서브도메인으로 직접 제작·추후 링크 연결 방침 확정.
  - `PRD.md` §3: "프로젝트 의뢰"/"오프라인 수업 문의" 페이지를 In Scope(이 저장소 내 폼 제작)에서 제외, Out of Scope(외부 서브도메인)로 이동 — business/studio 항목 추가.
  - `PRD.md` §6/§8: 외부 링크·준비중 배지 대상을 OJ/LMS → OJ/LMS/business/studio 4개로 확장, 폼 처리 방식 관련 미결 사항 제거(해당 페이지를 더 이상 이 저장소에서 만들지 않으므로).
  - `DEV_PLAN.md`: Phase 2("프로젝트 의뢰/오프라인 문의 페이지 제작")를 삭제하고, Phase 3(외부 연동 정리)에서 4개 서브도메인 링크 연결을 함께 다루도록 재구성.
- `index.html`을 직접 건드리는 리뉴얼 작업 특성상, 일단락될 때까지 `main` 병합 보류 방침 확정 → `DEV_PLAN.md` §2(브랜치 전략)에 반영. `dev`에만 커밋/푸시.
- `tasks/needs.md` 스펙대로 `index.html` 상단 내비게이션 1차 구현: 로고만 좌측, 나머지(원장님의 낙서/wonoj/LMS/business/studio + 1:1 상담 신청)는 우측 하나의 그룹으로 배치. oj/lms/business/studio 4개는 서브도메인이 아직 없어 "준비중" 배지가 붙은 비활성(`preventDefault`) 링크로 임시 처리, `원장님의 낙서`만 `graffiti.html`로 실제 연결. 데스크톱/모바일 메뉴 모두 클로드 인 크롬으로 로컬 서버(`localhost:8765`) 확인 완료 — 콘솔 에러 없음, 준비중 항목 클릭 시 이동 안 됨, 낙서 링크 정상 이동 확인. `PRD.md` §8 미결 사항에 임시 처리 방식 기록.
- 헤더의 "1:1 상담 신청" 버튼(데스크톱/모바일 모두)을 `#cta` 앵커 대신 구글 폼(`docs.google.com/forms/...`)으로 바로 연결, `target="_blank"`로 새 탭 오픈. 클로드 인 크롬으로 새 탭 오픈·원본 탭 유지 확인.
- 헤더 "wonoj" 항목을 "준비중" 비활성 상태에서 실제 링크(`https://oj.recode.ai.kr`, 새 탭)로 전환(데스크톱/모바일 모두). LMS/business/studio는 아직 "준비중" 상태 유지. `PRD.md` §8에 OJ 연결 완료 반영.
- `tasks/needs.md`가 "랜딩 2번째 레이어(히어로 + 우측 카테고리 게이지 버튼)" 요청으로 갱신됨을 확인. 검토 결과 `mockup.html` 히어로 섹션이 이미 거의 동일 구조(타이머 게이지 사이드 리스트)로 구현되어 있음을 발견 — 카테고리만 4개(Language/Algorithm/Web & WebApp/Unity & Unreal) → 5개(+ Agent AI, Unity & Unreal→Unity)로 조정 필요.
- Figma MCP로 신규 파일 "Recode Coding — Hero Wireframe" 생성(`https://www.figma.com/design/PBS0zISWDoNU3k87kJDvhs`) 후 해당 히어로 레이어(메인 배너 + 5개 카테고리 게이지 사이드 리스트)를 와이어프레임으로 제작, `mockup.html` 톤(인디고 브랜드, 다크 배경) 참고. 디자인 시스템 라이브러리가 없는 신규 파일이라 수동 구성, 폰트는 Pretendard 미설치로 Noto Sans KR 대체 사용. 스크린샷으로 사용자에게 전달, 실제 코드 반영은 아직 안 함(디자인 검토 단계).
- 같은 Figma 파일에 카테고리 게이지 표현 방식 3안(A. 버튼 하단 바 / B. 전체 배경 게이지 / C. 배지 원형 링)을 나란히 그려 비교본 제작, 사용자에게 전달.
- B(전체 배경 게이지)로 확정, `mockup.html`에 반영:
  - 히어로 사이드 리스트 4개 항목의 하단 바 게이지(`h-[3px]` 트랙)를 제거하고, 버튼 전체를 덮는 반투명 배경 채움(`data-gauge`, 카테고리별 accent 컬러 30% 투명도)으로 교체. `.side-item.is-active` 정적 하이라이트는 제거(게이지 채움 자체가 활성 표시 역할). JS(`activateSlide`)는 `[data-gauge]` 셀렉터를 그대로 써서 수정 없이 재사용됨.
  - 헤더 상단 내비게이션을 `index.html`과 동일하게 동기화: 로고를 "R/ Recode Coding"으로, 메뉴를 원장님의 낙서/wonoj(`oj.recode.ai.kr` 연결)/LMS·business·studio(준비중 배지)로, CTA를 구글 폼 직결로 교체. 기존엔 없던 모바일 메뉴(햄버거 버튼 + `assets/js/mobile-menu.js`)도 추가해 index.html과 동일 패턴으로 맞춤. Agent AI 5번째 카테고리 추가는 이번 범위에 포함하지 않음(미정, 필요시 별도 진행).
  - 클로드 인 크롬으로 로컬 서버 확인: 게이지가 왼쪽부터 점진적으로 채워지는 애니메이션과 6초 주기 자동 전환 정상 동작, 콘솔 에러 없음.
- `mockup.html` 색 톤을 `graffiti.html`(=index.html)과 맞추는 작업, 다크/라이트 두 옵션 중 "라이트 배경까지 전체 전환"으로 사용자 선택(일단 보고 최종 판단 예정) → 전체 파일 재작성:
  - Tailwind `brand` 팔레트를 인디고에서 `graffiti.html`/`index.html`과 동일한 에메랄드 그린으로 교체. 페이지 배경을 `#0c0c0f`(다크) → `#FBF7EE`(라이트 크림)로 전환, 본문 텍스트를 슬레이트 계열 밝은 톤으로 재조정.
  - 헤더/모바일 메뉴는 다크 유지(graffiti.html과 동일 패턴), 서브바·코스 카드·사이드 리스트·철학 컴팩트 리스트·푸터는 라이트 카드로 전환. 히어로 배너·철학 프로모 타일·CTA 대각선 배너는 의도적으로 다크 액센트 패널로 유지(라이트 페이지 위 스포트라이트 역할).
  - 5개 카테고리 사이드 리스트에 요청하신 대로 "Agent AI"를 5번째로 추가(보라 계열), 기존 4개는 각 색상 패밀리를 브랜드와 어울리게 재배정(Language=브랜드그린/Algorithm=틸/Web & WebApp=스카이블루/Unity=앰버). 04번 카테고리명도 "Unity & Unreal" → "Unity"로 단순화(needs.md 표기에 맞춤).
  - 새 "05 · Agent AI" 섹션(코스 카드 4개, 히어로 슬라이드, 사이드 게이지, 푸터 링크)을 다른 카테고리와 동일 패턴으로 추가.
  - 클로드 인 크롬으로 전체 스크롤 검증(히어로/4개 코스 섹션/신규 Agent AI 섹션/철학/CTA/푸터) + Agent AI 항목 클릭 전환 확인, 콘솔 에러 없음.
  - `PRD.md` §8 디자인 톤 미결 사항을 진행 상태로 갱신(최종 확정 아님, 사용자 검토 대기).
- `tasks/task-layer-01.md` 3개 항목 반영해 `mockup.html` 히어로 레이어 개선 (상세: `report/2026-08-21-mockup-hero-layer-01.md`):
  1. 우측 5개 카테고리 버튼을 `flex-1`로 균등 분배해 높이를 동일하게 맞추고, 그리드 stretch로 좌측 배너 높이와 자동 일치.
  2. 게이지 완성 → 다음 슬라이드 전환 시 배너 텍스트가 좌측으로 슬라이드 아웃 후 우측에서 슬라이드 인하는 애니메이션 추가(Epic Games Store 벤치마크 참고).
  3. 게이지/자동 전환 주기를 6초 → 3초로 단축.
  - 클로드 인 크롬으로 로컬 서버 확인: 버튼 높이 균등화, 클릭 시 전환 애니메이션 동작, 콘솔 에러 없음 확인.
- 히어로 슬라이드 전환 후속 반영: 텍스트만 슬라이딩되던 것을 배경 블롭(`hero-blob-1/2`)까지 포함해 하나의 장면(`#hero-scene`)으로 묶어 함께 슬라이딩/페이드되도록 확장. `hero-banner`(둥근 사각 틀)는 고정 창 역할만 유지. 클로드 인 크롬으로 전환 중간 프레임 확인, 콘솔 에러 없음.
