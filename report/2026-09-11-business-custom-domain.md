# 2026-09-11 — GNB business 링크를 커스텀 도메인으로 교체

`../business` 저장소에 커스텀 도메인 `business.recode.ai.kr`이 연결됐다는 사용자 알림에 따라 GNB 링크를 교체했다.

## 체크리스트

- [x] 장비 이동 프로토콜(`docs/CHANGE_DEVICE.md`) 선행 — pull(v0.93), gcloud Owner 로그인, 콘솔 대조 ✅, 실패 0건
- [x] `https://business.recode.ai.kr` 응답 확인(200)
- [x] `partials/header.html` 2곳(데스크톱 nav·모바일 메뉴) `business-1e563.web.app` → `business.recode.ai.kr`
- [x] `./scripts/build-partials.py` 실행 → 30장 반영, 옛 도메인 잔존 0건(`index.html` + `src/*.html` 30/30에 새 도메인 2곳씩)
- [x] 문서 6종 갱신(`CLAUDE.md` · `PRD` · `ARCHITECTURE` §6 다이어그램·표 · `DEV_PLAN` Phase 3 · `ACCOUNT_COST` §1 · `DEVLOG`)

## 요약

- **무엇**: GNB의 `business` 외부 링크 도메인 교체. `target="_blank" rel="noopener"` 등 마크업은 그대로.
- **왜**: 2026-08-26 활성화 당시 `../business`가 Firebase 기본 도메인으로만 배포돼 있어 "도메인 연결 후 재교체"를 예고해 뒀던 항목. 이제 활성화된 3개 서브도메인(wonoj·studio·business)이 전부 `*.recode.ai.kr`이다.
- **어떻게**: ADR D3 정본화 덕에 30장 60곳 치환이 아니라 정본 1파일 2곳 수정 + 빌드. studio 때(2026-08-25, 정본화 전)는 30장 60곳 일괄 치환이었다.

## 남은 것

- `main` 병합·배포는 별도 지시 전까지 하지 않는다(라이브는 아직 `business-1e563.web.app`을 가리킴 — 옛 도메인도 여전히 동작하므로 끊긴 상태는 아니다).
- 서브도메인 중 LMS만 "준비중" 상태로 남아 있다.
