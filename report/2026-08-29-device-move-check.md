# 2026-08-29 — 장비 이동 확인 (CHANGE_DEVICE 프로토콜 첫 실적용)

사용자가 다른 장비(`/Users/Wons`)로 옮겨와 "확인해 줘"라고 지시. `docs/CHANGE_DEVICE.md`가 신설된 뒤 이 프로토콜을 실제로 적용한 첫 사례다. 저장소는 이상 없었고, 정리가 필요한 것은 이 장비의 Claude Code 경로 키 상태였다.

## 체크리스트

- [x] §2 저장소 무결성 — remote/status/branch, 절대경로 하드코딩, 브랜치 pull, 로컬 서버 응답
- [x] §5 형제 저장소 확인 (`../business`, `../wonoj`)
- [x] §3 경로 키 상태 점검 (projects 디렉터리 · `.claude.json` · `history.jsonl` · 고아 아티팩트)
- [x] §4 이관 스크립트 작성 + 사본 검증 (실행은 사용자 몫 — 아래 "남은 이슈")
- [x] §7 전체 문서 정합성 확인
- [x] 프로토콜 문서 보강 + DEVLOG 기록

## §2 저장소 무결성 — 이상 없음

- **로컬이 원격보다 7커밋 뒤처져 있었다** (로컬 v0.51 / 원격 v0.58). 다른 장비에서 올린 v0.52\~v0.58을 `--ff-only`로 받고, 체크아웃하지 않은 `main`도 `origin/main`(v0.54)에 맞췄다. 프로토콜 §2의 "모든 브랜치 pull" 항목이 실제로 작동한 사례.
- 절대경로 하드코딩 0건(`*.html`/`*.js`/`*.css`/`*.sh` 전수).
- 로컬 서버 6개 경로 전부 200.
- 형제 저장소 `../business`(main)·`../wonoj`(dev) 모두 제자리 — `../business` 상대 참조 유효.

## §3 경로 키 상태 — 이 장비에도 옛 경로 잔재가 있었다

이 장비에서도 과거 `~/dev/recode-ai/*` → `~/recode-ai/*` 이동이 있었는데, **부분적으로만 정리된 상태**였다.

| 위치 | 상태 |
| --- | --- |
| `~/.claude/projects/` | 이미 새 경로 키만 존재 (정리됨) |
| `~/.claude.json` → `projects` | 옛 경로 6건 잔존 (home·business·wonoj-problem·nextjs-supabase-gcp-template 등) |
| `~/.claude.json` → `githubRepoPaths` | `re8code/home`·`business`·`wonoj-problem`·`nextjs-supabase-gcp-template`가 옛 경로를 함께 보유 |
| `~/.claude/history.jsonl` | 옛 경로 키 프롬프트 이력 **649건** |
| `file-history` / `session-env` | 고아 8개(210파일, 2.3MB) / 7개 |

→ 프로토콜 §3에 **"이 정리는 장비마다 따로 해야 한다"**(git으로 동기화되지 않는 `~/` 상태이므로)와 부분 정리 상태가 실제로 나온다는 점을 추가했다.

## §4 스크립트 — 작성·검증 완료, 실행은 사용자 몫

프로토콜 §4 템플릿을 이 장비의 실제 잔재에 맞춰 `PAIRS` 6쌍으로 조정하고, `GONE`은 비워뒀다(이력 손실 방지 — 아래 참고). 사본 검증 결과:

- 1회차: `projects` 4건 정리, `githubRepoPaths` 4개 저장소 정리, `history` 649건 이관
- 2회차: `NOCHANGE` (멱등 확인)
- 무결성: 최상위 키 74개 **개수·순서 보존**, 기존 새 경로 프로젝트 설정값 무변경, `wonoj-problem` 값 승계 동일, `history` 줄 수 1465 동일, **`display` 필드 전부 동일**(발화 원문 불변), 그 외 최상위 값 변경 없음

`GONE` 후보였던 `/Users/Wons/dev/recode-ai/studio`(이력 58건)·`/Users/Wons/dev/home`(50건)은 `GONE`에 넣으면 프롬프트 이력까지 삭제되므로 기본값에서 제외했다 — 이 판단을 프로토콜 §6 함정 7번으로 추가.

## §7 문서 정합성 — 불일치 0건

| 항목 | 결과 |
| --- | --- |
| 페이지 수 | 30장 |
| 공통 요소(tailwind-config·base.css·favicon·apple-touch-icon·OG 3종·로고·mobile-menu·`pt-16`·Pretendard) | 전부 30/30 |
| GNB `lg:` 3종 30/30, `md:` 잔존·인라인 `tailwind.config` | 0건 |
| 내부 링크 | 705건 중 깨짐 0건 |
| 카드 연결 | Language 5 / Algorithm 14 / Web 5 = `<a>` 24장, Unity·Agent AI 8장 비클릭 — 문서 서술과 일치 |
| CDN 버전 vs `ARCHITECTURE.md` §1 | Pretendard v1.3.9 / Swiper 11 / AOS 2.3.1 / Firebase 10.12.2 — 일치 |
| GNB 링크 vs §6 | oj·business·studio 활성, LMS만 "준비중" — 일치 |
| `§n` 상호참조 | 깨짐 0건 (ARCHITECTURE §1\~§8 존재) |
| 문서 세트 개수 표기 | `CLAUDE.md` "7개" 5곳 vs 실제 7개(`CLAUDE.md` + `docs/` 6) — 일치 |
| v0.57·v0.58 변경 | 1번 카드 "1. 출력(Output)" 5개 페이지 적용, 카드 제목 부제 0건, `curriculum-card` hover 규칙 0건, `lang-cp.html` `std::cout` 0건 — 문서 서술과 일치 |
| 로컬 서버 | 6개 경로 200 |

## 남은 이슈

1. **경로 키 이관 스크립트 미실행** — Claude Code 실행 중에는 `~/.claude.json` 편집이 무효화되므로(프로토콜 §6-1) 실행은 세션 종료 후여야 한다. 검증 완료본이 세션 스크래치패드에 있고, 사용자가 `~/migrate-claude-path.sh`로 복사해 실행해야 한다. 이번엔 저장소 밖 파일 생성이 권한 설정에 막혀 홈 디렉터리에 직접 두지 못했다(프로토콜 §6 함정 8번으로 기록).
2. **DEVLOG 버전 표기 커버리지** — 커밋 58개 중 24개(v0.01\~v0.14 초기 구간 + v0.19·v0.21\~v0.29 + 병합 기록 v0.51·v0.55)가 `vX.XX` 문자열 없이 날짜 항목으로만 남아 있다. 작업 내용 자체는 기록돼 있어 소급 보완은 지시가 있을 때.
3. 기존과 동일한 잔여 범위 — Unity·Agent AI 상세 페이지, 낙서장 본문 톤 조정(Phase 2), LMS 링크 활성화, 미참조 원본 이미지 9개(약 42MB, 크롭 소스로 의도적 보존).
