# 2026-09-01 — 낙서장 쓰기 계정을 목록으로 (ADR D4)

운영 계정을 `won@re8code.com`·`biz@re8code.com` 두 개로 옮기기로 하면서, 단일 계정을 전제로 하던 인증 구조를 목록 기반으로 바꿨다. **이행 1단계 — 세 계정을 함께 허용하는 상태까지.**

## 체크리스트

- [x] 값만 늘려서는 동작하지 않는다는 것을 코드에서 확인
- [x] `ADMIN_EMAIL`(문자열) → `ADMIN_EMAILS`(배열)
- [x] `signInAdmin(email, password)` + 목록 밖 주소 사전 차단
- [x] 로그인 모달에 이메일 입력칸 추가
- [x] `firestore.rules` `==` → `in [...]`
- [x] `check-device.sh` 단일 값 대조 → 순서 무관 목록 대조
- [x] ADR D4 신설 · D2에 "대체됨" 표기
- [x] `ACCOUNT_COST.md` · `ARCHITECTURE.md` · `CHANGE_DEVICE.md` · `CLAUDE.md` 갱신
- [x] 헤드리스 Chrome + CDP 검증 7항목
- [ ] **콘솔 작업 (사용자)** — Owner 추가 · Auth 사용자 등록 · 규칙 재게시
- [ ] **이행 2단계** — 검증 후 `triwon20@gmail.com` 제거

## 1. 값 교체가 아니라 기능 변경이었다

"계정 2개 추가"라는 지시를 값 추가로 처리하려다, 코드를 먼저 보고 멈췄다.

```js
// firebase-auth.js (변경 전)
signInWithEmailAndPassword(getAuthInstance(), ADMIN_EMAIL, password)
//                                            ^^^^^^^^^^^ 하드코딩
```

로그인 모달은 **비밀번호만** 받는다. 그래서 Authentication에 계정을 3개 등록하고 규칙을 열어줘도, 사이트는 언제나 `ADMIN_EMAIL` 하나로만 로그인을 시도한다 — 나머지 둘은 **등록만 되고 영영 쓰이지 않는다.**

이 구조는 2026-08-29 계정 통일(D2) 때 이미 한 번 문제가 됐던 지점이다. 그때는 "사이트가 `triwon20`으로 로그인을 시도조차 하지 않았다"는 형태로 나타났다.

## 2. 바꾼 것

| 파일 | 변경 |
| --- | --- |
| `firebase-config.js` | `ADMIN_EMAIL` → `ADMIN_EMAILS` 배열 (전부 소문자) |
| `firebase-auth.js` | `signInAdmin(email, password)` · `isAdminEmail()` 신설 · 정규화(trim+소문자) |
| `admin-auth.js` | 모달에 이메일 입력칸. 직전 주소는 `localStorage`에 저장 |
| `firestore.rules` | `token.email == "..."` → `token.email in ["...", ...]` |
| `check-device.sh` | `FIXED_ADMIN_MAIL` → `FIXED_ADMIN_MAILS`, 순서 무관 목록 대조 |

**목록에 없는 주소는 Firebase에 요청을 보내지 않는다.** 남의 주소로 비밀번호를 던져보는 통로가 되지 않도록, `signInAdmin`이 먼저 거절한다.

비밀번호는 저장하지 않는다 — `localStorage`에 남기는 것은 이메일뿐이고, 그것도 저장소 접근이 막힌 환경을 대비해 전부 `try/catch`로 감쌌다.

## 3. 검증

로컬 서버 + 헤드리스 Chrome(CDP)으로 실제 페이지에서 확인했다.

| 항목 | 결과 |
| --- | --- |
| `ADMIN_EMAILS` 로드 | 3건 정상 |
| 목록 밖 주소(`attacker@example.com`) | 거절 · **Firebase 요청 0건** |
| 목록 안 주소(`won@re8code.com`) | 요청 발생 2건 → 비밀번호 불일치로 실패 (정상) |
| 대소문자·공백 정규화 | `WON@RE8CODE.COM`·` biz@... ` 통과, 미등록 주소 거부 |
| 모달 입력칸 | 이메일(`type=email`)+비밀번호 2개, 이메일에 포커스 |
| 실패 시 동작 | 에러 노출 · 비밀번호만 비움 · 이메일 유지 |
| 콘솔 에러 | 0건 |

드리프트 탐지도 실제로 시험했다 — `firestore.rules`에서 계정 하나를 빼니 `config ≠ rules`로 정확히 잡혔고, 양쪽 목록을 함께 출력해 어디가 다른지 보여준다.

## 4. 남은 작업 — 콘솔 (사용자 몫)

순서가 중요하다. **저장소를 먼저 배포하고 규칙을 나중에 게시**해야 아무것도 끊기지 않는다(현재 코드는 세 계정을 모두 허용하므로 어느 순서든 옛 계정은 계속 동작한다).

1. Firebase 콘솔 → 프로젝트 설정 → 사용자 및 권한 → 두 계정을 **Owner**로 추가
2. Authentication → Users → 두 계정을 이메일/비밀번호 사용자로 **등록**(비밀번호 설정)
3. Firestore Database → 규칙 → `firestore.rules` 내용을 붙여넣고 **게시**
4. 낙서장에서 **두 계정 각각으로** 실제 글쓰기 검증

## 5. 이행 2단계 — `triwon20@gmail.com` 제거

4번이 확인된 뒤에 별도 커밋으로 진행한다. 저장소 세 곳에서 주소를 빼고, 콘솔에서 Owner 제거 + Auth 사용자 삭제 + 규칙 재게시.

**그 전에 반드시 정리해야 할 것 — 1:1 상담 Google Forms.** 양식과 쌓인 응답이 `triwon20@gmail.com`의 Drive에 있고, 이는 Firebase 권한 이전과 **완전히 다른 절차**다. 이걸 옮기지 않은 채 계정을 정리하면 상담 접수가 끊긴다. `ACCOUNT_COST.md` §1 표와 §2에 명시해 뒀다.

## 남은 이슈

- `won@re8code.com`은 2026-08-29에 **삭제했던 주소**를 다시 쓰는 것이다. 같은 문자열이지만 그때는 정리 대상이었고 지금은 새 운영 계정이라, 문서에서 두 사건이 헷갈리지 않도록 §2에 경위를 남겼다.
- git 커밋 author(`re8code <won@re8code.com>`)와 `../business`의 `/privacy` 문의 창구 표기는 **별개 신원**이라 이번 변경과 무관하다.
- 계정이 늘어난 만큼 비밀번호 관리 지점도 늘어난다. 저장소는 어느 비밀번호도 알지 못한다 — `CHANGE_DEVICE.md` §5 "저장소에 없는 값"에 해당한다.
