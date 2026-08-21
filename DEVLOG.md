# DEVLOG.md — 작업 일지

## 2026-08-21
- Figma MCP 서버를 project scope로 등록.
  - 처음엔 `.mcp.json`에 직접 `figma` 서버(`https://mcp.figma.com/mcp`)를 추가했으나, 이미 `figma@claude-plugins-official` 플러그인(user scope, MCP 서버 + `figma-use` 등 스킬 12개 포함)이 설치되어 있어 중복 확인됨.
  - 논의 후 플러그인을 유지하되 scope만 user → project로 변경하기로 결정: `claude plugin uninstall figma` → `claude plugin install figma@claude-plugins-official --scope project`. `.claude/settings.json`의 `enabledPlugins`에 등록되어 git으로 팀과 동기화됨.
  - 수동으로 추가했던 `.mcp.json`의 `figma` 항목은 중복이라 제거(빈 파일도 삭제).
  - `claude mcp login plugin:figma:figma`로 OAuth 인증 완료, `claude mcp list` 기준 `✔ Connected` 확인.
- "작업 완료 후 PRD.md/DEV_PLAN.md/CLAUDE.md/DEVLOG.md 4개 문서 점검" 규칙을 `CLAUDE.md`의 "저장소 관례" 섹션에 명문화.
