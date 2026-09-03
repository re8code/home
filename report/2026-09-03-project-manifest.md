# 2026-09-03 — 프로젝트 매니페스트(`.project-meta.json`) 생성

`tasks/매니페스트-생성-지시서.md` 수행. 여러 프로젝트를 가로질러 계정·비용·스택을 취합하는 외부 도구가 읽을 **기계 판독용 매니페스트**를 이 저장소에 하나 만들었다. 코드 변경 없음.

## 체크리스트

- [x] 루트·`docs/`의 md 문서 전수 검토 (`.github/`는 없음)
- [x] 설정 파일 확인 (`package.json` 없음 — `CNAME`·`firestore.rules`·`assets/js/firebase-config.js`로 대체)
- [x] 외부 호스트 전수 조사로 문서 누락 서비스 탐색
- [x] `.project-meta.json` 생성 (stack 7 · services 8)
- [x] public 저장소이므로 `.gitignore`에 추가
- [x] `CHANGE_DEVICE.md` §5 정정 — "gitignore로 빠지는 파일이 없다"가 더 이상 사실이 아니게 됨
- [x] `ACCOUNT_COST.md` §5에 정본/사본 관계 명시

## 1. 무엇을 만들었나

| | |
| --- | --- |
| 파일 | `.project-meta.json` (저장소 루트, **gitignore 대상**) |
| `project.status` | `production` |
| `stack` | 7항목 — 정적 HTML / Tailwind Play CDN / Vanilla JS / Firestore / Firebase Auth / GitHub Pages / Python(도구) |
| `services` | 8항목 — 닷홈 · GitHub · Firebase · Google Forms · CDN 4종 |

지시서의 원칙 두 가지가 이 저장소에서 특히 크게 작용했다.

**① 코드에서 알 수 있는 것은 넣지 않는다.** 취합 도구가 "선언된 스택"과 "실제 감지된 의존성"을 대조해 낡은 기록을 찾아내는 구조이므로, 매니페스트가 코드를 베낀 것이면 그 대조가 무의미해진다. 그래서 `stack[].version`을 **전부 `null`로 뒀다** — Firebase SDK 10.12.2·Swiper 11·AOS 2.3.1·Pretendard 1.3.9는 `ARCHITECTURE.md` §1에 적혀 있지만 옮기지 않았다. 개별 라이브러리(Swiper·AOS)도 `stack`에서 뺐다. 남긴 것은 "무엇을 쓰기로 정했는가"뿐이다 — 빌드 도구를 두지 않기로 한 결정, Play CDN 선택, 관리형 DB로 Firestore를 고른 것.

**② 추측하지 않는다 — 특히 비용.** 아래 §2.

## 2. 비용은 한 칸도 채우지 못했다 (의도된 결과)

`ACCOUNT_COST.md` §5가 **"구체적 금액·요금제 수치는 적지 않는다"**를 방침으로 두고 있어, 저장소 어디에도 금액이 없다. 유일하게 확정 지출인 닷홈 도메인조차 `cycle: "yearly"`만 적고 `amount`는 `null`이다.

이 둘은 **충돌이 아니라 같은 판단**이다. `ACCOUNT_COST.md`가 금액을 안 적는 이유("바뀌면 곧바로 틀린 문서가 된다")와, 지시서가 추정을 금지하는 이유("사람이 추측값인지 구분할 수 없게 되고 합계가 조용히 틀어진다")가 같은 곳을 가리킨다. 그러므로 **매니페스트의 금액은 문서에서 채울 수 없고, 사람이 콘솔 값을 보고 직접 넣어야 하는 칸**이다.

`updated_at`은 오늘 날짜지만 **미검증 상태**다.

## 3. `null`로 남긴 필드

| 필드 | 이유 |
| --- | --- |
| 모든 `cost.amount`(무료 항목의 `0` 제외) · `cost.currency` | 위 §2. 닷홈은 한국 등록대행사라 KRW가 거의 확실하지만 **문서 근거가 아니라 상식**이라 비웠다 |
| `dothome`의 `owner_email` · `renewal` · `plan` | 문서에 없다. **갱신일은 채워둘 값 1순위** — 이것이 끊기면 사이트와 서브도메인 4개가 한꺼번에 죽는다 |
| `github.owner_email` | 계정이 사용자명 `re8code`로만 적혀 있고 로그인 이메일은 문서에 없다 |
| 모든 `account_ref`/`billing_ref`/`recovery_ref` | 비밀번호 관리자 사용 흔적이 문서에 없다. 쓰고 있다면 채울 자리 |
| 모든 `seats` | 좌석 개념이 있는 유료 서비스가 없다 |
| 모든 `stack[].version` | §1 ① |

## 4. 판단이 갈릴 수 있는 곳 — Firebase를 `medium`으로 뒀다

지시서의 기준표는 "DB·인증 = `high`"라고 하지만, 여기 Firebase는 **낙서장 한 곳에만 걸려 있다.** 멈춰도 나머지 29장은 그대로 서빙되고 방문자는 아무것도 눈치채지 못한다. 기준표의 문구가 아니라 정의("없으면 서비스가 죽는다")를 따라 `medium`으로 적고 `note`에 근거를 남겼다.

반대로 **Tailwind Play CDN은 `high`**로 뒀다. 계정도 비용도 없지만 장애가 나면 30장 전부의 스타일이 즉시 깨진다 — `ACCOUNT_COST.md` §4가 가용성 리스크로 따로 다루는 항목이다.

## 5. 서브도메인 3개는 넣지 않았다

`oj`·`mate`·`business`는 이 저장소 밖의 **별도 프로젝트**이고(`ARCHITECTURE.md` §6), 지시서 자체가 "각 프로젝트 폴더에서 각각 실행한다"는 전제로 쓰여 있다. 여기에 적으면 취합 시 이중 계상된다. `project.note`에 그 사실만 남겼다.

특히 **`oj`·`mate`의 Cloud Run이 이 생태계의 과금 개연성 1순위**인데(결제 계정 연결 필수), 그 기록은 각 프로젝트의 매니페스트에 들어가야 한다.

## 6. 검증

**문서에 없는데 코드에서 발견된 외부 서비스 — 없다.** `index.html`·`src/`·`assets/`·`partials/`의 외부 호스트를 전수 조사한 결과:

```
docs.google.com · cdn.jsdelivr.net · cdn.tailwindcss.com · www.gstatic.com
unpkg.com · oj.recode.ai.kr · mate.recode.ai.kr · business-1e563.web.app
```

전부 `ACCOUNT_COST.md`·`ARCHITECTURE.md`에 이미 있다. **문서와 코드가 어긋난 곳이 없다** — 계정 정리를 막 끝낸 직후라 그런지 이 저장소의 기록은 현행이다.

문서 간 모순도 새로 발견된 것은 없다. 이미 정정된 것이 하나 있는데(`ACCOUNT_COST.md` §2-1 — "서브도메인도 전부 `triwon20` 소유"라던 서술이 사실과 달랐던 건), 문서가 스스로 그 경위를 밝히고 있어 현재 상태는 일관된다.

## 7. ⚠️ 저장소에 평문으로 있는 값 (매니페스트에는 넣지 않았다)

지시서의 "작업 중 실제 키나 비밀번호를 발견하면 별도로 경고한다"에 해당한다. **둘 다 이미 public 저장소에 커밋돼 있다.**

1. **`assets/js/admin-auth.js:10` — `DEV_FALLBACK_PASSWORD` 평문.** `CHANGE_DEVICE.md` §5가 이미 "비밀번호로 취급하지 말 것"으로 다루고 있는, `IS_PLACEHOLDER_CONFIG`일 때만 쓰이는 로컬 폴백이다. 실서비스 경로에서는 쓰이지 않는다. **다른 곳에서 쓰는 비밀번호와 겹치지만 않으면 문제없다** — 그것만 확인하면 된다.
2. **`assets/js/firebase-config.js` — Firebase 웹 `apiKey`.** 설계상 클라이언트가 받아야 하는 공개 값이라 유출이 아니다. 실제 접근 통제는 `firestore.rules`가 하고, 지금 그 규칙이 쓰기를 계정 하나로 제한하고 있다.

## 8. `.gitignore` — 추가했다

저장소가 **public**이므로(`ACCOUNT_COST.md` §2) 지시서 지침대로 추가했다. 매니페스트에는 계정 이메일 3개(`won@`·`biz@`·`triwon20@`)가 들어간다.

```
.project-meta.json
```

`git check-ignore -v`로 실제로 무시되는 것까지 확인했다.

**부작용 하나 — 이 파일은 다른 장비로 따라가지 않는다.** 지금까지 이 저장소는 gitignore로 빠지는 파일이 하나도 없어서(`CHANGE_DEVICE.md` §5가 "저장소에는 gitignore로 빠지는 설정 파일이 없다"고 명시하고 있었다) "새 장비에서 파일을 복원해야 하는" 상황 자체가 없었는데, 이번에 처음 생겼다. §5 서두를 정정하고 준비물 표에 행을 추가했다 — 값을 옮기는 게 아니라 **이 지시서로 다시 생성**하면 된다는 점까지 적었다.

## 남은 이슈

- **금액·닷홈 갱신일은 사람만 아는 값이다.** 검토하며 채워야 매니페스트가 제 역할을 한다(§2·§3).
- 취합 도구가 어떤 식으로 이 파일들을 모으는지는 모른다 — gitignore된 파일을 로컬에서 훑는 방식일 것으로 보이나, 확인되면 §8의 판단(공개 저장소라 커밋하지 않음)을 다시 볼 여지가 있다.
- 서브도메인 3개 프로젝트에서 같은 작업이 각각 필요하다(§5).
