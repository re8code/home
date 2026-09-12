# 2026-09-12 — 매니페스트 재생성 (지시서 v0.26 — 0단계 CLI 사전 점검 첫 적용)

새 장비에 클론한 뒤 `tasks/매니페스트-생성-지시서.md`를 수행해 `.project-meta.json`을 다시 만들었다. 코드 변경 없음. **이번 실행의 새로운 점은 결과가 아니라 절차**다 — 지시서 v0.26이 신설한 **0단계(CLI 사전 점검)**를 처음으로 수행했다.

## 체크리스트

- [x] 장비 이동 점검(`./scripts/check-device.sh`) — 실패 0건, `dev` 체크아웃
- [x] 지시서 사본 vs 정본(`../project-registry/tasks/...`) 대조 — v0.26 동일
- [x] **0단계 CLI 사전 점검 — 미로그인 3건을 보고하고 턴을 끝냈다**
- [x] 사람 판단("이대로 진행") 수령 후 1~3단계 수행
- [x] `.project-meta.json` 생성 (stack 7 · services 8)
- [x] 자가 검증 — 스키마 위반 0건 · 자격증명 키워드 0건
- [x] 외부 호스트 전수 조사 — 문서에 없는 서비스 0건
- [x] 지시서 사본이 커밋본보다 새 판이었던 것을 커밋에 반영

## 1. 0단계 — 이 절차가 실제로 한 일

v0.26이 0단계를 **작업을 멈추는 단계**로 바꿨다(그 전까지 "이 단계는 작업을 막지 않는다"고 적혀 있었고, 그 결과 실제 세션에서 로그인 안내 없이 매니페스트가 만들어졌다는 경위가 지시서에 남아 있다). 이 장비는 클론 직후라 **관련 CLI가 전부 미로그인**이었다.

| CLI | 상태 | 걸려 있는 것 |
| --- | --- | --- |
| `gh` | 미로그인 | GitHub `re8code/home` |
| `gcloud` | 미로그인(자격 증명 0건) | Firebase `graffiti-3b1fc` |
| `firebase` | 미로그인 | 〃 |
| 닷홈 · Google Forms | **CLI 없음** | 로그인으로는 영영 풀리지 않는다 |

보고 후 사용자가 **"이대로 진행"**을 선택해, 미로그인 항목은 `owner_email`을 비우고 아래 §4 질문 목록으로 올렸다.

**여기서 구분이 하나 필요했다.** Firebase와 Google Forms는 CLI로 확인하지 못했지만 `owner_email`을 채웠다 — 지시서의 찾는 순서가 ① CLI ② 레포 문서 ③ 사람이고, 이 둘은 **문서에 명시적 근거**가 있기 때문이다(`ACCOUNT_COST.md` §2·§2-1의 ADR D4 정리 결과). 추측이 아니라 2순위 출처를 쓴 것이고, CLI로 대조하지 못했다는 사실은 이 보고서에 남긴다. 반대로 닷홈·GitHub은 문서에도 답이 없어 비웠다.

## 2. 결과는 다섯 번째 반복 — stack 7 · services 8

2026-09-03·09-04·09-05(오전)·09-05(조직 귀속)에 이어 다섯 번째 생성이고, 구성은 그대로다. 금액은 한 칸도 채우지 못했고(`ACCOUNT_COST.md` §5가 금액을 적지 않는 방침이라 문서에서 파생될 수 없다), `stack[].version`은 전부 비웠다(취합 도구가 선언 스택과 감지 의존성을 대조하는 구조라 코드를 베끼면 대조가 무의미해진다). 판단 근거는 `report/2026-09-03-project-manifest.md`가 정본이므로 되풀이하지 않는다.

지난 실행(2026-09-05) 이후 저장소에 있었던 변화 중 매니페스트에 닿는 것은 **없었다** — v0.92~v0.96은 GNB 순서·라벨·`business` 커스텀 도메인 교체로, 전부 이 저장소 밖 서브도메인의 표기 문제라 `services`에 항목이 없다. `project.note`의 조직 귀속 서술(ADR D5)과 `services[firebase].note`는 지난 판 그대로 유지했다.

한 곳만 새로 적었다 — `google-forms`의 `note`에 **폼 URL이 정본 밖 27곳에 하드코딩돼 있다**는 사실(2026-09-10 실측). 소유권 이전 방향(Drive 소유권만 이전, URL 불변)이 이 제약과 직접 맞물리기 때문이다.

## 3. 자가 검증

고정값 6종(허용 목록 · `ai-api`/`mobile` 미사용) · `provider` 소문자 슬러그 · `cycle: usage`의 `amount` · 무료 항목의 `free_tier_limit` · **`category: cdn`에 `free_tier_limit`을 서술로 적지 않았는지** · `account_required: false`와 `owner_email` 충돌 · 자격증명 키워드 · JSON 파싱 — **위반 0건.**

`.gitignore` 적용도 `git check-ignore -v`로 확인했다(`.gitignore:8`).

## 4. ★ 사람에게 묻는 것 — 갈래가 다르다

| 갈래 | 항목 | 사람이 할 일 |
| --- | --- | --- |
| CLI 로그인이면 풀림 | **GitHub `re8code`의 로그인 이메일** | `gh auth login` 후 재지시 (`gh api user` ↔ `gh repo view` 소유자 대조) |
| 〃 | Firebase `owner_email` **대조** (현재 문서 근거로 `won@re8code.com`) | `gcloud auth login`(Owner) 후 재지시 — `check-device.sh`의 콘솔 대조 경고도 함께 풀린다 |
| **CLI가 없어 영영 안 풀림** | **닷홈 계정 주소 · 도메인 갱신일** | 값을 직접 알려줘야 한다 |

닷홈은 다섯 번째로 비어 있는 칸이고, **끊기면 사이트와 서브도메인 4개가 한꺼번에 죽는** 자리라 우선순위가 가장 높다. 그다음이 `cost.amount`(닷홈 연 갱신액)와 `*_ref` 3종 — 이 칸을 사람이 채우는 것이 이 파일의 존재 이유다.

## 5. 부수 확인

- **문서에 없는데 코드에서 발견된 외부 서비스 — 없다.** 전수 조사 결과 `docs.google.com`·`cdn.jsdelivr.net`·`cdn.tailwindcss.com`·`www.gstatic.com`·`unpkg.com`과 서브도메인 3개(`oj`·`mate`·`business`)뿐이고 전부 문서에 있다. `www.w3.org`는 SVG 네임스페이스 선언이라 서비스가 아니다.
- **문서 간 모순 — 새로 발견된 것 없다.**
- **평문 자격증명** — `assets/js/admin-auth.js`의 `DEV_FALLBACK_PASSWORD`와 Firebase 웹 `apiKey` 둘 다 여전히 커밋돼 있다. 성격과 판단은 `report/2026-09-03-project-manifest.md` §7에 이미 정리돼 있고 변화 없다(매니페스트에는 넣지 않았다).
- **지시서 사본이 커밋본보다 새 판이었다** — 작업 트리의 파일은 정본과 동일한 v0.26인데 커밋된 것은 그 이전 판이었다. 이번 커밋에 포함시켜 저장소의 사본을 정본에 맞췄다.

## 남은 이슈

- 닷홈 계정·갱신일, GitHub 로그인 이메일 — §4.
- Google Workspace 유·무료 확인(2026-09-05 발견, 관리 콘솔 구독 화면에서만 가능) — 여전히 미확인.
- `.project-meta.json`은 gitignore 대상이라 이 생성은 **이 장비에만** 남는다. 다음 장비에서 또 만들어야 한다(`CHANGE_DEVICE.md` §5).
