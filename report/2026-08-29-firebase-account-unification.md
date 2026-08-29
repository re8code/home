# 2026-08-29 — Firebase 계정 정리 및 통일 (수정 불가 확정)

사용자가 "계정을 명확히 정리하는 중, 이번에 정확히 잡아 수정불가 사항으로 기록"하겠다고 하여, 흩어져 있던 계정 값을 조사하고 `triwon20@gmail.com` 하나로 통일했다.

## 체크리스트

- [x] 저장소에 박힌 계정 값 전수 조사 (코드·규칙·문서)
- [x] 콘솔 계정과 쓰기 계정이 **다른 레이어**임을 확인하고 근거 수집
- [x] 실제로 어느 계정으로 글쓰기가 이뤄졌는지 라이브 데이터로 검증
- [x] 사용자 결정에 따라 `triwon20@gmail.com`으로 통일 (코드 2곳 + 스크립트 고정값)
- [x] `ACCOUNT_COST.md` §2에 "수정 불가" 절, `ARCHITECTURE.md` ADR D2 기록
- [x] `check-device.sh`에 3중 대조(config·rules·ADR 고정값) 추가
- [x] **콘솔 작업 완료** — Auth 사용자 등록 · 규칙 재게시 · 글쓰기 검증 · 옛 사용자 삭제 (아래 "완료 확인")

## 무엇이 얽혀 있었나

문서가 서로 다른 두 가지를 "Firebase 계정" 하나로 적어 두어 답이 두 개인 상태였다.

| | 콘솔 계정 | 규칙의 `token.email` |
| --- | --- | --- |
| 정체 | Google 계정 + IAM(Owner) | Firebase **Authentication에 등록된 최종 사용자** |
| 하는 일 | 규칙 게시·요금제·Auth 사용자 생성 | 브라우저에서 로그인해 글을 씀 |
| 핵심 | **콘솔 Owner라도 클라이언트 규칙에서는 특권이 없다** — Auth 사용자로 등록돼 있지 않으면 글을 못 쓴다 | |

정리 전 실제 상태: 콘솔 `triwon20@gmail.com` / 쓰기 `won@re8code.com` — **갈라져 있었고, 그 상태로 정상 동작 중이었다.**

## 근거 수집 — 어느 계정으로 글이 써졌나

1. `firebase-auth.js`의 로그인은 `signInWithEmailAndPassword(auth, ADMIN_EMAIL, password)` — **이메일이 코드에 하드코딩**돼 있고 화면은 비밀번호만 받는다. 즉 사이트는 `triwon20@gmail.com`으로 로그인을 **시도조차 하지 않았다**.
2. Firestore를 공개 read로 조회하니 문서 1건이 존재했다("첫번째 낙서를 하며...", 필드 `id·title·content·date·views`). 이는 `graffiti-new.html`의 `createPost({ id, title, content, date, views })`와 **필드 구성이 정확히 일치** — 콘솔에서 수동 생성한 게 아니라 사이트를 통해 쓴 것이다.
3. 글쓰기는 인증 게이트를 통과해야 실행되고, placeholder 모드였다면 `createPost`가 `null`을 반환해 아무것도 저장되지 않는다.

→ **Authentication에 `won@re8code.com` 사용자가 실제로 존재했고, 게시된 규칙도 그 이메일을 허용하고 있었다**는 뜻이다. 문서가 틀렸던 게 아니라, 두 계정이 실제로 달랐던 것.

한계도 분명히 해 둔다 — 콘솔 Auth 사용자 목록과 **게시된** 규칙은 여기서 확인할 수 없다. 공개 웹 키로 Identity Toolkit `createAuthUri`를 호출해 등록 여부를 보려 했으나 **이메일 열거 보호**가 켜져 있어 두 이메일 모두 판별되지 않았다.

## 결정과 반영

사용자 선택: **`triwon20@gmail.com`으로 통일** + ACCOUNT_COST·ADR에 수정 불가로 기록.

| 위치 | 변경 |
| --- | --- |
| `assets/js/firebase-config.js` | `ADMIN_EMAIL` → `triwon20@gmail.com` (+ ADR D2를 가리키는 주석) |
| `firestore.rules` | `token.email` → `triwon20@gmail.com` |
| `scripts/check-device.sh` | `FIXED_ADMIN_MAIL` 고정값 신설 — config·rules·ADR 고정값 **3중 대조** |
| `docs/ACCOUNT_COST.md` §2 | 계정 3개 중 Google 항목을 통합 서술 + "계정 값은 수정 불가" 절(레이어 차이 표, 바꿀 때 고쳐야 할 세 곳) |
| `docs/ARCHITECTURE.md` | §5 서술·mermaid 노드 갱신, **ADR D2** 신설(맥락·결정·트레이드오프) |
| `docs/CHANGE_DEVICE.md` §5 | 장비 점검 표의 Firebase 행에 통일 사실 명시 |

## 콘솔 작업 — 순서 (전부 완료)

이 변경은 **저장소만으로 완결되지 않는다.** 아래를 마치기 전에는 낙서장 글쓰기가 막힌다.

1. **Firebase 콘솔 → Authentication → Users**: `triwon20@gmail.com`이 이메일/비밀번호 사용자로 등록돼 있는지 확인하고, 없으면 추가한다. (이게 빠지면 새 코드로도 로그인 자체가 실패한다.)
2. **`main` 병합 → 배포**: 바뀐 `ADMIN_EMAIL`이 실서비스에 반영된다.
3. **Firebase 콘솔 → Firestore → 규칙**: 저장소의 `firestore.rules` 내용을 붙여넣고 **게시**한다. 규칙은 코드에서 자동 배포되지 않는다.
4. 확인: 낙서장에서 실제로 글을 한 건 써 본다.
5. 정리: 옛 사용자 `won@re8code.com`은 규칙상 더 이상 쓰기가 불가하지만 계정 목록에 남아 혼선이 되므로 삭제를 권한다(삭제 여부는 사용자 판단).

2·3번 사이에는 로그인은 되지만 쓰기가 거부되는 짧은 구간이 생긴다 — 두 단계를 붙여서 진행하면 된다.

## 완료 확인 (같은 날)

- **Auth 사용자 등록 → 규칙 재게시 → 글쓰기 검증** 순으로 진행. 처음 등록만 하고 규칙을 게시하지 않은 상태에서 글쓰기가 실패했는데, 이는 예상된 동작이다(로그인은 되지만 규칙이 옛 이메일을 요구해 거부). 규칙 게시 후 성공.
- 검증 근거: 라이브 Firestore 문서의 `createTime`이 `2026-08-29T16:05`로 갱신됨 — 새 계정으로 실제 쓰기가 이뤄졌고, 따라서 **게시된 규칙이 `triwon20@gmail.com`을 허용**한다는 실증이다.
- 첫 글은 사용자가 새 계정으로 재등록했고, 작업 전 떠둔 스냅샷과 대조해 **제목 동일·본문 188자 완전 일치**를 확인했다(유실 없음).
- **옛 사용자 `won@re8code.com` 삭제 완료.** 게시글에는 영향 없음(문서에 작성자 필드 자체가 없다). 같은 주소가 `../business`의 `/privacy`에 개인정보 문의 창구로 표기돼 있으나 그건 메일 주소 표기일 뿐이고, 삭제한 것은 이 Firebase 프로젝트의 인증 레코드라 무관하다.
- 최종 상태: 저장소 3곳(`firebase-config.js`·`firestore.rules`·`check-device.sh` 고정값) · 배포본 · 콘솔 규칙이 모두 `triwon20@gmail.com`으로 일치.
