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
