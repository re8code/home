# 2026-08-29 — 저장소 경로 이동 마무리 + ADR 절 신설

이 장비에서 `home` 저장소가 `~/dev/recode-ai/home` → `~/recode-ai/home`으로, 이어서 형제 저장소 `business`도 `~/recode-ai/business`로 옮겨졌다. 저장소가 실제로 깨진 곳이 없는지 확인하고, **경로를 키로 보관되던 Claude Code 로컬 상태**를 정리했다. 이어서 사용자가 `CLAUDE.md`에 추가한 ADR 규칙에 따라 `docs/ARCHITECTURE.md`에 §8 ADR 절을 신설했다.

## 체크리스트

- [x] 이동 후 저장소 무결성 확인 (git remote·브랜치·워킹트리, 절대경로 하드코딩 0건, 로컬 서버 응답)
- [x] `business` 이동 확인 — `../business` 상대 참조가 다시 유효, 문서의 `../business` 표기 수정 불필요함을 확인
- [x] 옛 경로의 Claude Code 프로젝트 디렉터리 삭제 (세션 트랜스크립트 포함 105MB)
- [x] `~/.claude.json`의 옛 경로 키 정리 (`projects` · `githubRepoPaths`)
- [x] `~/.claude/history.jsonl`의 입력 이력 288건을 새 경로로 이관 (사용자 발화 원문은 보존)
- [x] 사라진 저장소(`wonoj`) 관련 기록 삭제
- [x] 고아 아티팩트 삭제 (`file-history` 19MB·561파일, `session-env` 2건)
- [x] 재발 대비 정리 스크립트 작성 및 사본 검증 (`~/cleanup-old-home-path.sh`, 저장소 밖)
- [x] `dev`·`main` 및 `business` 원격 변경분 pull
- [x] `CLAUDE.md` 신규 규칙 2종 확인 (ADR / `vX.XXX` 버전 표기)
- [x] `docs/ARCHITECTURE.md` §8 ADR 절 신설 + §7에 연결 문장 추가

## 1. 저장소는 경로 독립적이었다 — 깨진 곳 없음

| 확인 항목 | 결과 |
| --- | --- |
| HTML/CSS/JS의 절대경로 하드코딩 | 0건 (상대경로 또는 `/assets/...` 루트 절대참조) |
| `start.sh` | `BASH_SOURCE` 기준으로 저장소 루트를 계산 — 실행 위치 무관 |
| git remote·브랜치·워킹트리 | `git@github.com:re8code/home.git`, `dev`/`main` 정상, clean |
| 로컬 서버 응답 | `/index.html`·`/assets/css/base.css`·`/assets/js/tailwind-config.js`·`/src/about.html`·`/assets/image/og-image.png` 전부 200 |
| `../business` 상대 참조 | `business`도 함께 이동해 **다시 유효** — `CLAUDE.md`·`ARCHITECTURE.md`·`DEVLOG.md`의 기존 표기 수정 불필요 |

`/assets/...` 루트 절대참조는 로컬에서도 저장소 루트가 곧 서버 루트라 이동과 무관하게 동작한다.

## 2. 실제로 깨지는 것은 "도구가 경로를 키로 들고 있는 상태"였다

저장소 밖(`~/.claude*`)에 경로를 키로 저장된 상태가 남아 있었다. 저장소에는 영향이 없지만, 이동하면 세션 이력·신뢰 설정이 따라오지 않는다.

| 대상 | 처리 |
| --- | --- |
| `~/.claude/projects/-Users-won-dev-recode-ai-home/` | 삭제 (세션 트랜스크립트 105MB, 사용자 확인 후) |
| `~/.claude.json` — `projects` 키, `githubRepoPaths` | 옛 경로 제거 (신뢰 설정은 새 경로 항목이 이미 보유) |
| `~/.claude/history.jsonl` — `project` 필드 288건 | 새 경로로 이관 (home 231 + business 57) |
| `~/.claude/history.jsonl` — `wonoj` 기록 6줄 | 삭제 (해당 저장소가 이 장비에서 사라짐) |
| `~/.claude/file-history/37410b75-.../` | 삭제 (19MB·561파일 — 삭제된 옛 세션의 고아 스냅샷) |
| `~/.claude/session-env/` 고아 2건, `~/.claude/backups/` 6건 | 삭제 |

**`display` 필드 13건은 의도적으로 보존했다** — 사용자가 실제로 타이핑한 프롬프트 본문 안에 옛 경로가 들어 있는 것으로, 경로 키가 아니라 발화 기록이다. 바꾸면 과거 발화를 위조하게 된다.

### 주의 — 실행 중 편집은 조용히 사라진다

Claude Code는 `~/.claude.json`을 메모리에 들고 있다가 종료 시 되쓴다. 그래서 정리 스크립트(`~/cleanup-old-home-path.sh`, **저장소 밖에 둔다** — 저장소 안에 두면 `git status`를 더럽힌다)는 claude 프로세스가 하나라도 살아 있으면 중단한다. `history.jsonl`은 실행 중에도 append되므로 `os.replace`(inode 교체)가 아니라 **같은 inode를 유지하는 제자리 재작성**으로 처리했다.

스크립트의 안전장치: 프로세스 검사, 타임스탬프 백업 + 실패 시 롤백, 임시 파일에 쓰고 되읽어 JSON 검증 후 원자적 쓰기, 완전 일치만 치환, 멱등.

**검증** — 스크립트에 박힌 파이썬을 그대로 꺼내 `.claude.json`·`history.jsonl` **사본**으로 실행했다(원본 mtime 불변). 최상위 키 62개 개수·순서 보존, 새 경로 항목 값 완전 동일, 그 외 무변경, 재실행 시 `NOCHANGE`. 오염을 주입한 사본에서는 4가지 변경을 정확히 복구하고 `display` 원문은 보존했다.

**최종 스캔** — `.claude.json` `projects`/`githubRepoPaths`, `history.jsonl` `project` 필드에서 존재하지 않는 경로 0건, `file-history`·`session-env` 고아 세션 0건.

## 3. `CLAUDE.md` 신규 규칙 2종

사용자가 직접 추가했다.

| 규칙 | 조치 |
| --- | --- |
| `ARCHITECTURE.md` 마지막 항목은 ADR을 기록한다 | §8 신설 (아래) |
| minor 버전이 100을 넘으면 `vX.XXX` 양식으로 전환 | 현재 v0.51 — 규칙 자체로 완결, 조치 불필요 |

## 4. `ARCHITECTURE.md` §8 ADR 절 신설

점검 결과 문서에 ADR 절이 **아예 없었다**("ADR" 문자열 0건, 마지막 절은 §7 갱신 원칙). v0.50에서 신설된 §1(기술 스택)과 짝을 이루는 §마지막(ADR)만 비어 있는 상태였다.

**소급 기록은 하지 않는다.** 사용자 지시("ADR은 추가로 적용되는 사항이 있으면 기록하도록")에 따라 과거 결정을 되짚어 채우지 않고 **자리와 기록 규약만** 정했다. 지금까지의 구조적 배경은 §1~§6 서술과 `report/*.md`·`DEVLOG.md`에 이미 남아 있다.

정한 규약:

- 표기법은 형제 저장소 `../business/docs/ARCHITECTURE.md`(D1~D16 운용 중)를 그대로 따른다 — `### D<번호>. <결정 한 문장>` 아래 **맥락 / 결정 / 트레이드오프**.
- 번호는 다음 결정부터 `D1`로 시작하고 순차 증가. 뒤집힌 결정은 지우지 않고 "→ D\<n\>으로 대체됨"을 덧붙인다.
- 기록 대상은 되돌리기 어렵거나 이후 작업의 전제가 되는 선택(호스팅·배포, 백엔드/데이터 저장소, 브랜치 전략, 공통부 분리 방식, 페이지 생성 단위 등). 개별 페이지의 카피·색상·레이아웃 조정은 `DEVLOG.md`·`report/`에 남긴다.

§7 갱신 원칙에도 "새 아키텍처 결정은 §8에 추가한다" 한 줄을 추가해 두 절을 연결했다.

## 검증 결과

- `docs/ARCHITECTURE.md` 목차 §1~§8, ADR이 마지막 절임을 확인.
- 사이트 산출물(HTML/CSS/JS/이미지) 변경 없음 — 배포 영향 없음.

## 남은 이슈

- **정리 스크립트를 세션 종료 후 한 번 실행할 것.** Claude Code가 종료 시 메모리 상태를 되쓰면서 옛 경로 항목이 되살아날 수 있다. 되살아난 것이 없으면 `이미 정리되어 있습니다`로 끝난다(멱등).
- `wonoj`는 이 장비에서 사라졌다. 원격(`git@github.com:re8code/wonoj.git`)은 살아 있으므로 필요해지면 `~/recode-ai/wonoj`로 clone한다.
