# 2026-09-05 — `graffiti-3b1fc`를 `re8code.com` 조직에 귀속 (ADR D5)

낙서장 Firebase 프로젝트를 무소속(no organization)에서 `re8code.com` 조직 소속으로 옮겼다. **저장소 코드 변경 없음** — 문서만 갱신했다.

## 체크리스트

- [x] 조직·프로젝트 현황 조회 — 조직이 이미 존재함을 확인
- [x] 이동 전 스냅샷 확보 (parent · IAM · 게시된 규칙 · Auth 사용자 · 익명 공개 읽기)
- [x] 조직 정책 검토 — 이동으로 깨질 IAM 바인딩이 있는지 사전 확인
- [x] `roles/resourcemanager.projectMover` 부여 후 `gcloud beta projects move` 실행 (사용자가 직접 실행)
- [x] 이동 후 스냅샷 대조 — 6개 항목 전부 일치
- [x] `./scripts/check-device.sh` 콘솔 대조 통과
- [x] `ARCHITECTURE.md` §8 ADR D5 · `ACCOUNT_COST.md` §2-1 갱신

## 1. 출발점 — "귀속시킬까?"가 아니라 "왜 둘만 밖에 있지?"였다

사용자 질문("GCP에서 re8code.com 조직으로 귀속시키는 거 어때? 가능은 해?")을 확인하러 조회했더니 **조직은 이미 있었다.**

| | |
| --- | --- |
| 조직 | `re8code.com` — ID `438985008538`, Cloud Identity `C0471rvuc` |
| `won@re8code.com` | `roles/resourcemanager.organizationAdmin` |
| 이미 소속 | `recodemate`(mate 서브도메인) · `my-cash-won` |
| 무소속 | **`graffiti-3b1fc`** · **`business-1e563`** |
| 확인 불가 | `oj`의 `project-5886…` — `won`에게 목록에 나오지도 않음(다른 계정 소유) |

즉 새로 만드는 작업이 아니라 **뒤처진 둘을 맞추는 작업**이었고, ADR D4(계정을 `won`·`biz`로 이전)의 논리적 다음 단계였다. D4는 프로젝트 *안*의 권한을 옮겼을 뿐, 프로젝트 *자체*는 개인 계정의 IAM 바인딩에만 매달려 있었다.

## 2. 사전 리스크 검토 — 도메인 제한 공유

조직에 `constraints/iam.allowedPolicyMemberDomains`가 걸려 있고 허용값은 `C0471rvuc` 하나다. 조직에 들어가면 `allUsers` 같은 외부 멤버를 IAM에 **새로 붙일 수 없다.** 이번 대상이 안전한 근거 셋을 이동 전에 확보했다.

1. `graffiti-3b1fc`의 IAM에 `allUsers`/`allAuthenticatedUsers`/외부 도메인 멤버가 **0건**이다(전수 확인).
2. 낙서장의 공개 읽기는 IAM이 아니라 **`firestore.rules`**가 통제하고, 로그인 계정은 **Authentication 사용자**라 IAM 멤버가 아니다 — 정책과 접점이 없다.
3. 이미 조직 안에 있는 `recodemate`가 **프로젝트 레벨 예외 없이** Cloud Run `roles/run.invoker: allUsers`를 유지한 채 정상 동작 중이다. 조직 정책은 정책을 *쓰는 시점*에 평가되므로 기존 바인딩은 소급 차단되지 않는다.

## 3. 실행 — 권한 한 개가 빠져 있었다

`organizationAdmin`에는 `resourcemanager.projects.move`가 **포함돼 있지 않다**(역할 권한 목록으로 확인). 조직 관리자가 스스로 `roles/resourcemanager.projectMover`를 부여한 뒤 이동해야 한다.

```bash
gcloud organizations add-iam-policy-binding 438985008538 \
  --member="user:won@re8code.com" --role="roles/resourcemanager.projectMover"
gcloud beta projects move graffiti-3b1fc --organization=438985008538
```

**`gcloud projects move`는 GA 트랙에 없다** — `Invalid choice: 'move'` 오류가 나므로 `beta`(또는 `alpha`)를 붙여야 한다. 두 명령 모두 조직 IAM을 건드리는 동작이라 Claude Code의 권한 게이트에 막혀 사용자가 직접 실행했다.

## 4. 검증 — 스냅샷 6항목 전부 일치

| 항목 | 이동 전 | 이동 후 |
| --- | --- | --- |
| parent | 없음 | `organization / 438985008538` ✅ |
| IAM 바인딩 | 7개 역할 | **동일**(owner `won`·`biz`, 서비스 에이전트 5개 그대로) |
| 게시된 규칙 | ruleset `b5df9d8a…` | **동일** |
| Auth 사용자 | `won@re8code.com` 1명 | **동일** |
| **익명 공개 읽기** | 성공(1건) | **성공(1건)** |
| `check-device.sh` | — | `게시된 규칙` ✅ · `Auth 사용자` ✅ |

익명 공개 읽기는 `apiKey`만으로 Firestore REST에 `graffiti_posts`를 조회한 것이다 — 방문자가 낙서장 목록을 보는 실제 경로라, 이게 이동 전후로 같으면 사용자 관점에서 깨진 것이 없다는 뜻이다.

`gcloud projects list --filter=parent.id=...`에는 이동 직후 잠깐 나오지 않았다가 재조회 시 나타났다 — 목록은 검색 인덱스라 반영이 늦고, 권위 있는 값은 `describe`다. 인덱스 지연을 실패로 오인하지 말 것.

## 5. Firebase 쪽 작업은 없었다

Firebase 프로젝트는 GCP 프로젝트와 같은 것이라 컨테이너만 옮기면 되고, Firebase 콘솔에는 "조직 이전" 메뉴 자체가 없다. `projectId`가 그대로여서 `assets/js/firebase-config.js`(apiKey·authDomain·projectId·storageBucket)도 손대지 않았다.

## 남은 이슈

- **`business-1e563`이 다음 차례다.** 옮기기 전에 그쪽 배포가 **서비스 계정 키에 의존하는지** 확인해야 한다 — 조직의 `iam.disableServiceAccountKeyCreation` 때문에 키를 새로 발급할 수 없다(이미 발급된 키는 계속 동작).
- **`oj`는 프로젝트 접근 권한 확보가 선행**되어야 한다. 그리고 Cloud Run 공개 호출을 IAM(`allUsers`)으로 열고 있어, 이동 후 재배포 과정에서 그 바인딩을 다시 붙여야 하는 상황이 오면 정책 예외가 필요하다 — 이번 둘과 달리 **실제 관문이 있는 케이스**다.
- **결제 계정은 따라오지 않는다.** `won`에게 보이는 결제 계정이 0건이라 결제는 다른 계정 소유이고, 과금 개연성 1순위인 `oj`·`mate` 비용을 조직에서 통합해 보려면 별도 이전 작업이 필요하다.
- **되돌릴 수 없다** — 조직 밖(무소속)으로 되돌리는 경로는 지원되지 않는다.
