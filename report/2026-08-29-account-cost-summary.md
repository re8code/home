# 2026-08-29 — 계정·비용 요약 문서 신설 (`docs/ACCOUNT_COST.md`)

사용자가 빈 파일로 만들어 둔 `docs/account-cost.md`(같은 날 `ACCOUNT_COST.md`로 개명 — 아래 §3)에, `ARCHITECTURE.md` §1 기술 스택 중 **계정이 필요한 항목**과 **비용 발생 개연성이 있는 항목**을 정리했다. 문서에 적기 전에 저장소 실물과 실서비스 응답으로 전부 확인했다 — 추측으로 채운 항목은 없다.

## 체크리스트

- [x] 저장소가 참조하는 외부 호스트 전수 조사
- [x] 각 호스트의 실제 운영 주체·계정 소속 확인 (DNS·응답 헤더·GitHub API)
- [x] 저장소 공개 여부 확인 (GitHub Pages 무료 조건)
- [x] Firebase 사용 범위 확인 (Blaze 전환 필요 여부 판단 근거)
- [x] `docs/account-cost.md` 작성 (§1~§5)
- [x] `ARCHITECTURE.md` §1 · `CLAUDE.md` 저장소 관례에 상호참조 추가
- [x] `DEVLOG.md` 기록, 보고서 작성, 커밋·푸시

## 1. 확인 방법과 결과

문서에 적을 사실을 전부 실측했다.

| 확인 항목 | 방법 | 결과 |
| --- | --- | --- |
| 참조 외부 호스트 | `index.html`·`src/*.html`·`assets/**` URL 전수 추출 | 7종 — `docs.google.com`(87) / `cdn.jsdelivr.net`(62) / `oj`·`mate`·`business` 서브도메인(각 60) / `cdn.tailwindcss.com`(30) / `www.gstatic.com`(3) / `unpkg.com`(2). `w3.org`는 SVG 네임스페이스라 네트워크 요청 아님 |
| CDN 실체 | URL 상세 확인 | jsDelivr = Pretendard 1.3.9 + Swiper 11, unpkg = AOS 2.3.1, gstatic = Firebase SDK 10.12.2 — §1 기술 스택 표와 일치 |
| 도메인/DNS | `dig NS recode.ai.kr` | `ns1~3.dothome.co.kr` — **닷홈 계정이 도메인·DNS 정본** |
| 저장소 공개 여부 | GitHub API `repos/re8code/home` | `"private": false` → **Pages 무료 조건 충족** |
| `oj.recode.ai.kr` | 응답 헤더 | `server: Google Frontend` |
| `mate.recode.ai.kr` | 응답 헤더 | `server: Google Frontend` + `x-cloud-trace-context` → Cloud Run (`CLAUDE.md`의 `recodemate-...-du.a.run.app` 이력과 일치) |
| Firebase 사용 범위 | SDK import 전수 | `firebase-app`/`auth`/`firestore` 3개뿐 — **Storage·Functions 미사용** |

## 2. 문서에 담은 결론

- **필수 계정 3개**: 닷홈(도메인·DNS) / GitHub `re8code`(저장소·Pages) / Google `won@re8code.com`(Firebase + Forms). CDN 4종은 계정이 필요 없다.
- **확정 지출은 도메인 갱신 하나뿐** — 나머지는 전부 무료 한도 안에서 돌고 있다.
- **과금 개연성 1순위는 Cloud Run**(`oj`·`mate`). 결제 계정이 연결돼 있어야 동작하는 구조라, 무료 한도를 넘으면 별도 확인 없이 청구된다. 다만 두 서비스 모두 **이 저장소가 아니라 별도 프로젝트 소관**이므로 예산 알림은 그쪽에서 설정해야 한다는 점을 명시했다.
- **Firebase는 Spark라 초과 시 과금이 아니라 차단** — 돈보다 "낙서장이 조용히 멈춘다"가 실질 리스크다. Storage·Functions를 쓰지 않으므로 **Blaze로 올릴 이유가 아직 없다**는 판단 근거도 함께 남겼다.
- **GitHub Pages는 저장소를 비공개로 바꾸는 순간 유료 플랜이 필요**해진다. `assets/image/`의 재크롭용 원본 PNG ~42MB 때문에 용량 리밋을 먼저 만날 수 있다는 점도 적었다.
- 비용은 아니지만 함께 볼 리스크 3가지: 무료 공개 CDN 의존(Tailwind Play CDN은 공식적으로 프로덕션 권장 대상이 아님) / 단일 Google 계정 집중 / `firestore.rules` 수동 게시.

### 의도적으로 하지 않은 것

**구체적 금액·요금제 수치를 적지 않았다.** 요금제는 수시로 바뀌어 적는 순간 낡은 문서가 되므로, "어떤 조건에서 과금으로 넘어가는가"만 유지하고 금액은 각 서비스 콘솔을 정본으로 두는 원칙을 문서 §5에 못박았다. 계정 자격 증명도 적지 않는다는 원칙을 함께 넣었다.

## 3. 문서 세트 내 위치

`account-cost.md`는 `CLAUDE.md` 제1원칙의 **6개 문서에 포함하지 않았다** — 매 작업마다 훑어야 할 governance 문서가 아니라, 외부 서비스 도입·요금제 변경 시에만 갱신하는 보조 참고 문서이기 때문이다(6개 세트에 넣을지는 사용자 판단 영역이라 임의로 승격하지 않았다). 대신 고아 문서가 되지 않도록 상호참조를 양쪽에 걸었다.

- `ARCHITECTURE.md` §1 도입부 — "각 항목의 **계정·비용** 측면만 뽑은 요약은 `account-cost.md`에 따로 둔다."
- `CLAUDE.md` 저장소 관례 `docs/` 항목 — 보조 참고 문서임과 갱신 시점을 한 줄로 명시.

## 검증 결과

- 문서에 적은 사실은 전부 위 §1의 실측에 근거 — 미확인 추정치 없음.
- 사이트 산출물(HTML/CSS/JS/이미지) 변경 없음 — 배포 영향 없음.

## 남은 이슈

- **Cloud Run 실제 사용량·예산 알림은 확인하지 못했다** — `oj`/`mate`는 별도 프로젝트라 이 저장소에서 접근 범위 밖이다. 해당 프로젝트에서 Google Cloud 예산 알림이 설정돼 있는지 사용자가 직접 확인할 필요가 있다.
- `lms.recode.ai.kr`은 아직 호스팅 방식이 정해지지 않아 비용 항목을 비워뒀다 — 오픈 시 이 문서에 추가한다.

## 4. 후기 — 같은 날 사용자가 제1원칙 문서로 승격

보고서 작성 직후 사용자가 파일을 **`docs/ACCOUNT_COST.md`로 개명**(다른 문서와 같은 대문자 규칙)하고 `CLAUDE.md` 제1원칙 목록에 직접 추가해, **문서 세트가 6개 → 7개**가 되었다. 위 §3의 "보조 참고 문서로 두었다"는 판단은 이 결정으로 대체된다.

이에 따라 어긋난 표기를 정정했다 — `CLAUDE.md`의 개수 표기 4곳(제1원칙 도입부·장비 간 연속성·작업 완료 후 점검 열거·"n개 중"), `docs/` 폴더 설명(5개→6개 주요 문서, 보조 문서 서술 제거), `ARCHITECTURE.md` §1의 파일명 참조. 문서별 갱신 기준에도 `ACCOUNT_COST.md` 한 줄(외부 서비스 도입·요금제 변경 시에만 갱신, 금액은 적지 않음)을 추가했다.
