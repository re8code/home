# 2026-09-01 — 낙서장 쓰기 계정을 목록으로 (ADR D4)

운영 계정을 옮기기로 하면서, 단일 계정을 전제로 하던 인증 구조를 목록 기반으로 바꿨다. **콘솔 Owner는 `won`·`biz` 둘, 낙서장 쓰기는 `won` 하나** — 두 레이어의 계정 수를 의도적으로 다르게 뒀다. **이행 1단계 — 옛 계정과 함께 허용하는 상태까지.**

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
- [x] 낙서장 Auth는 하나로 확정 (Owner만 둘)
- [ ] **이행 2단계** — 검증 후 `triwon20@gmail.com` 제거

## 1. 값 교체가 아니라 기능 변경이었다

"계정 2개 추가"라는 지시를 값 추가로 처리하려다, 코드를 먼저 보고 멈췄다.

```js
// firebase-auth.js (변경 전)
signInWithEmailAndPassword(getAuthInstance(), ADMIN_EMAIL, password)
//                                            ^^^^^^^^^^^ 하드코딩
```

로그인 모달은 **비밀번호만** 받는다. 그래서 Authentication에 계정을 여러 개 등록하고 규칙을 열어줘도, 사이트는 언제나 `ADMIN_EMAIL` 하나로만 로그인을 시도한다 — 나머지는 **등록만 되고 영영 쓰이지 않는다.**

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
| `ADMIN_EMAILS` 로드 | 정상 (검증 시점 3건 → 확정 2건) |
| 목록 밖 주소(`attacker@example.com`) | 거절 · **Firebase 요청 0건** |
| 목록 안 주소(`won@re8code.com`) | 요청 발생 2건 → 비밀번호 불일치로 실패 (정상) |
| 대소문자·공백 정규화 | `WON@RE8CODE.COM`·` biz@... ` 통과, 미등록 주소 거부 |
| 모달 입력칸 | 이메일(`type=email`)+비밀번호 2개, 이메일에 포커스 |
| 실패 시 동작 | 에러 노출 · 비밀번호만 비움 · 이메일 유지 |
| 콘솔 에러 | 0건 |

드리프트 탐지도 실제로 시험했다 — `firestore.rules`에서 계정 하나를 빼니 `config ≠ rules`로 정확히 잡혔고, 양쪽 목록을 함께 출력해 어디가 다른지 보여준다.

## 3-1. 왜 쓰기 계정은 하나인가

처음에는 두 계정을 양쪽 레이어에 다 넣었다가, "낙서 쓸 때마다 둘 중 하나를 골라야 하느냐"는 질문을 계기로 되짚었다.

**게시글에 작성자 필드가 없다.** `firebase-client.js`가 저장하는 것은 `id · date · title · views · content`뿐이라, 어느 계정으로 쓰든 결과물이 같고 화면에서 구분되지도 않는다. 즉 쓰기 계정을 늘려도 **얻는 것 없이 로그인 지점만 늘어난다.**

반면 콘솔 Owner는 둘이 의미 있다 — 한 계정이 잠겨도 프로젝트 관리 권한을 잃지 않는다.

그래서 **Owner 2 / 쓰기 1**로 갈랐다. `biz@re8code.com`은 관리 전용이고 `ADMIN_EMAILS`에는 없다. 나중에 `won` 계정이 잠기면 목록에 `biz`를 넣고 재게시하면 복구되지만, 그건 배포와 콘솔 작업이 필요한 절차라 즉시 전환은 아니다.

덧붙여 **모달은 거의 뜨지 않는다.** Firebase가 로그인 상태를 브라우저에 유지하고 로그아웃 호출부가 아예 없어서(`signOutAdmin`을 부르는 곳 0건), 새 브라우저·시크릿창·사이트 데이터 삭제 후에나 나타난다. 그때도 직전 이메일이 채워지고 커서는 비밀번호 칸으로 간다.

## 4. 남은 작업 — 콘솔 (사용자 몫)

순서가 중요하다. **저장소를 먼저 배포하고 규칙을 나중에 게시**해야 아무것도 끊기지 않는다 — 현재 목록이 `triwon20`과 `won` 둘이라, 어느 순서로 하든 옛 계정은 계속 동작한다.

1. Firebase 콘솔 → 프로젝트 설정 → 사용자 및 권한 → **두 계정(`won`·`biz`)을 Owner로 추가**
2. Authentication → Users → **`won@re8code.com`만** 이메일/비밀번호 사용자로 등록(비밀번호 설정) — `biz`는 등록하지 않는다
3. Firestore Database → 규칙 → `firestore.rules` 내용을 붙여넣고 **게시**
4. 낙서장에서 `won` 계정으로 실제 글쓰기 검증

## 5. 이행 2단계 — `triwon20@gmail.com` 제거

4번이 확인된 뒤에 별도 커밋으로 진행한다. 저장소 세 곳에서 주소를 빼고, 콘솔에서 Owner 제거 + Auth 사용자 삭제 + 규칙 재게시.

**그 전에 반드시 정리해야 할 것 — 1:1 상담 Google Forms.** 양식과 쌓인 응답이 `triwon20@gmail.com`의 Drive에 있고, 이는 Firebase 권한 이전과 **완전히 다른 절차**다. 이걸 옮기지 않은 채 계정을 정리하면 상담 접수가 끊긴다. `ACCOUNT_COST.md` §1 표와 §2에 명시해 뒀다.

## 남은 이슈

- `won@re8code.com`은 2026-08-29에 **삭제했던 주소**를 다시 쓰는 것이다. 같은 문자열이지만 그때는 정리 대상이었고 지금은 새 운영 계정이라, 문서에서 두 사건이 헷갈리지 않도록 §2에 경위를 남겼다.
- git 커밋 author(`re8code <won@re8code.com>`)와 `../business`의 `/privacy` 문의 창구 표기는 **별개 신원**이라 이번 변경과 무관하다.
- 낙서장 쓰기 비밀번호는 여전히 하나뿐이지만, 콘솔 Owner가 둘이라 **Google 계정 자격 증명 관리 지점은 늘었다**. 저장소는 어느 것도 알지 못한다 — `CHANGE_DEVICE.md` §5 "저장소에 없는 값"에 해당한다.
- `biz@re8code.com`은 `ADMIN_EMAILS`에 없으므로 **Authentication에 등록하지 않는다.** 등록해두면 목록에 없어 로그인이 거절되므로 혼란만 남는다.
