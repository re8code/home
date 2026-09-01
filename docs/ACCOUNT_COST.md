# ACCOUNT_COST.md — 계정·비용 요약

`ARCHITECTURE.md` §1 기술 스택(및 §3 배포·§5 백엔드·§6 서브도메인)에서 **계정이 필요한 항목**과 **비용이 발생할 개연성이 있는 항목**만 뽑아 정리한다. 구조 설명은 `ARCHITECTURE.md`가 정본이고, 이 문서는 "누구 계정으로 무엇이 돌아가고, 어디서 돈이 샐 수 있는가"만 다룬다.

- 최종 갱신: 2026-09-01 (운영 계정을 `won@re8code.com`·`biz@re8code.com`로 옮기는 중 — ADR D4로 D2를 대체. 서브도메인 프로젝트가 `triwon20`이 아닌 **별도 계정** 소유였음을 확인해 §2를 정정, §2-1). 이전 갱신: 2026-08-31 (서브도메인 2개의 실제 호스팅 경로 재확인, §3) · 2026-08-29 (계정을 `triwon20@gmail.com` 하나로 통일하고 **수정 불가**로 확정 — ADR D2. 신설 — 같은 날 `CLAUDE.md` 제1원칙 문서 세트에 편입되어 7개 문서 중 하나가 됨)
- 확인 방법: 저장소 내 외부 호스트 전수 조사 + 실서비스 응답 헤더/DNS 조회
- **금액은 적지 않는다** — 요금제는 수시로 바뀌므로 각 서비스 콘솔의 값이 정본이다. 여기에는 "과금으로 전환되는 조건"만 적는다.

## 1. 한눈에 보기

| 항목 | 계정 | 현재 비용 | 과금 전환 조건 |
| --- | --- | --- | --- |
| 도메인 `recode.ai.kr` (닷홈) | 닷홈 | **유료(연 단위)** | 이미 발생 중 — 갱신 실패 시 도메인 상실 |
| GitHub + GitHub Pages | GitHub `re8code` | 무료 | 저장소를 **비공개로 전환**하면 Pages에 유료 플랜 필요 |
| Firebase (Firestore + Auth) | 콘솔 Owner `won@re8code.com`·`biz@re8code.com` / 낙서장 쓰기 `won@re8code.com` (이행 중 — 옛 `triwon20@gmail.com` 병행) | 무료(Spark) | 무료 한도 초과 시 **차단**(Spark는 자동 과금 없음). Blaze로 올리면 과금 시작 |
| Google Forms (1:1 상담) | Google `triwon20@gmail.com` — **이번 계정 이전 대상이 아니다**(§2) | 무료 | 사실상 없음 (Drive 용량 한도만) |
| CDN 4종 (Tailwind·jsDelivr·unpkg·gstatic) | 계정 불필요 | 무료 | 없음 — 대신 **가용성 리스크** (§4) |
| `oj.recode.ai.kr` / `mate.recode.ai.kr` | Google Cloud — `home`과 **다른 계정 체계**(§2-1) | **결제 계정 연결 필수** | 이 생태계에서 **과금 개연성 1순위** (§3) |
| `business-1e563.web.app` | Google (Firebase) — §2-1 | 무료(Spark) | 호스팅 전송량/용량 한도 초과 시 |
| `lms.recode.ai.kr` | 미정 | 없음 | 오픈 시 호스팅 방식에 따라 결정 |

## 2. 계정이 필요한 항목

이 저장소를 운영하는 데 **반드시 있어야 하는 계정은 3개**다.

1. **닷홈** — 도메인 `recode.ai.kr` 등록·DNS. 네임서버가 `ns1~3.dothome.co.kr`로 확인됨. GitHub Pages와 4개 서브도메인의 A/CNAME 레코드가 전부 여기 걸려 있어, **이 계정을 잃으면 사이트와 서브도메인이 한꺼번에 끊긴다.**
2. **GitHub (`re8code`)** — 저장소 `re8code/home` + GitHub Pages 배포. 저장소는 **public**이라 Pages가 무료다.
3. **Google 계정** — Firebase 프로젝트 `graffiti-3b1fc`(Firestore + Authentication)와 1:1 상담 Google Forms가 여기 걸려 있다. 2026-09-01부터 **Firebase는 콘솔 Owner를 `won@re8code.com`·`biz@re8code.com` 둘로, 낙서장 쓰기는 `won@re8code.com` 하나로 옮기는 중**이고(ADR D4), **Google Forms는 여전히 `triwon20@gmail.com` 소유**다 — 양식과 쌓인 응답이 그 계정 Drive에 있어 Firebase 권한 이전과는 전혀 다른 절차가 필요하다. **`triwon20@gmail.com`을 정리할 때 이 양식을 함께 옮기지 않으면 상담 접수가 끊긴다.**

### 2-1. 서브도메인 프로젝트는 이 저장소와 계정 체계가 다르다 (2026-09-01 확인)

**이 문서가 2026-08-29부터 "Firebase·Forms·서브도메인의 Google Cloud가 모두 `triwon20@gmail.com` 한 계정"이라고 적어 온 것은 사실과 달랐다.** 서브도메인 프로젝트들은 별도 계정이 소유하고 있었고, 사용자가 이를 `won@re8code.com`·`biz@re8code.com`으로 통합하는 중이다.

| 프로젝트 | 쓰이는 곳 | 계정 정리 상태 |
| --- | --- | --- |
| `graffiti-3b1fc` | 이 저장소의 낙서장 | `triwon20` → 이행 중 (ADR D4) |
| `business-1e563` | `business` 서브도메인 | `won`·`biz` 추가됨 — **옛 계정 제거는 미완** |
| `project-5886…` | `oj` 서브도메인 | 아직 변경 전 |
| `recodemate` | `mate` 서브도메인 | 정리 완료 |

- **확인 방법**: `gcloud projects list --account=<계정>` · `gcloud projects get-iam-policy <프로젝트> --flatten="bindings[].members" --format="table(bindings.role,bindings.members)"`. 상태는 계속 바뀌므로 **여기 적힌 표가 아니라 명령 결과가 정본**이다.
- **서비스 계정은 건드리지 않는다.** `oj` 프로젝트의 `github-deployer@…`는 `run.admin`·`firebasehosting.admin`·`artifactregistry.writer`를 가진 **CI 배포 주체**다. 사람 계정을 정리하면서 함께 지우면 배포가 멈춘다.
- 서브도메인 프로젝트의 실제 관리는 이 저장소가 아니라 각 프로젝트 쪽 몫이다(`ARCHITECTURE.md` §6). 여기에는 "어느 계정 아래 있는가"만 적는다.

### 계정 목록은 세 곳이 일치해야 한다 (2026-09-01, ADR D4)

**콘솔 Owner와 낙서장 쓰기 계정은 개수가 다르다.** 관리 권한은 둘로 이중화하되, 쓰기 계정은 하나만 둔다 — 게시글에 작성자 필드가 없어 계정을 늘려도 구분되는 것 없이 로그인 지점만 늘기 때문이다(ADR D4).

| 계정 | 콘솔 Owner | 낙서장 쓰기 |
| --- | --- | --- |
| `won@re8code.com` | ✅ | ✅ |
| `biz@re8code.com` | ✅ | — (관리 전용) |
| `triwon20@gmail.com` | **제거 예정** | **제거 예정** — `won`으로 쓰기가 검증된 뒤 |

쓰기 계정은 단일 값이 아니라 **목록**으로 다룬다 — 이행 중에는 둘이고, `biz`를 임시로 넣어야 할 상황(`won` 계정 잠김 등)에도 코드 구조를 바꾸지 않고 목록만 고치면 된다.

값을 바꿀 때는 **세 곳을 함께** 고치고 콘솔에 규칙을 재게시해야 한다 — `assets/js/firebase-config.js`의 `ADMIN_EMAILS`, `firestore.rules`, `scripts/check-device.sh`의 `FIXED_ADMIN_MAILS`. 세 목록의 일치는 `./scripts/check-device.sh`가 순서 무관하게 매번 대조하고, **콘솔 쪽 실제 상태 두 가지도 함께 받아와 대조한다**(2026-09-01 추가) — ① 게시된 Firestore 규칙이 `firestore.rules`와 같은가, ② `ADMIN_EMAILS`의 계정이 Authentication에 실제로 등록돼 있는가. 그 프로젝트를 읽을 수 있는 `gcloud` 자격 증명이 있는 장비에서만 동작하고, 없으면 조용히 건너뛴다.

종전에 "이메일 열거 보호 때문에 Auth 사용자 존재를 확인할 수 없다"고 적어 둔 것은 **클라이언트 API 기준**이었다. 관리자 API(`identitytoolkit … accounts:query`)로는 조회되며, 그래서 이제 자동 대조된다. 남아 있는 유일한 미확인 항목은 **비밀번호가 맞는지**뿐이고, 그건 실제로 로그인해 보는 수밖에 없다.

**계정마다 비밀번호가 따로다.** 저장소는 그중 어느 것도 알지 못하고, 알아서도 안 된다 — `CHANGE_DEVICE.md` §5의 "저장소에 없는 값"에 해당한다.

콘솔 계정과 Auth 사용자는 원래 **다른 레이어**라 갈라질 수 있고, 실제로 2026-08-29까지 갈라져 있었다.

| | 콘솔 계정 | 규칙의 `token.email` |
| --- | --- | --- |
| 정체 | Google 계정 + IAM(Owner) | Firebase **Authentication에 등록된 최종 사용자** |
| 하는 일 | 규칙 게시·요금제·Auth 사용자 생성 | 브라우저에서 로그인해 글을 씀 |
| 주의 | **콘솔 Owner라도 클라이언트 규칙에서는 아무 특권이 없다** — Auth 사용자로 등록돼 있지 않으면 글을 못 쓴다 | |

`won@re8code.com`은 2026-08-29에 한 번 삭제했다가 **2026-09-01 운영 계정으로 다시 등록한다**(ADR D4) — 같은 주소지만 그때는 정리 대상이었고 지금은 새 운영 계정이다. 같은 주소가 형제 저장소 `../business`의 `/privacy` 페이지에 **개인정보 보호책임자 문의 창구**로 표기돼 있는데, 그건 대외 공개용 메일 주소일 뿐 로그인 계정이 아니다 — 여기서 삭제한 것은 이 Firebase 프로젝트의 인증 레코드이지 메일 계정이 아니므로 그 표기는 그대로 유효하다. git 커밋 author(`re8code <won@re8code.com>`)도 별개 신원이라 영향 없다.

계정이 **필요 없는** 것: Tailwind Play CDN·jsDelivr(Pretendard, Swiper)·unpkg(AOS)·gstatic(Firebase SDK) — 전부 익명 공개 CDN이다.

## 3. 비용 발생 개연성

### 확정적으로 나가는 돈 — 도메인뿐

현재 **정기적으로 결제되는 것은 `recode.ai.kr` 도메인 갱신 하나**다. 나머지는 전부 무료 한도 안에서 돌고 있다.

### 개연성 1순위 — Google Cloud (서브도메인 2개)

`oj.recode.ai.kr`·`mate.recode.ai.kr` 둘 다 **Google Cloud에서 돌고 있다.** DNS는 Firebase Hosting(`project-5886...web.app` / `recodemate.web.app`)을 가리키지만, 정적 호스팅이 아니라 그 뒤의 **Cloud Run으로 넘어간다** — 응답에 `x-cloud-trace-context`가 붙고 루트 요청이 `/login`으로 동적 리다이렉트되는 것이 근거다(studio가 원래 `recodemate-...-du.a.run.app`으로 연결돼 있던 이력과도 맞는다). **Cloud Run은 결제 계정이 연결돼 있어야 동작**하므로, 무료 한도를 넘는 순간 별도 확인 없이 청구된다 — 이 생태계에서 실제로 돈이 샐 가능성이 가장 높은 지점이다.

정리하면 **GCP를 안 쓰는 게 아니라, 이 저장소가 안 쓰는 것**이다. 이 저장소(`recode.ai.kr`)는 GitHub Pages에 올라가고 GCP 접점은 Firebase(Firestore·Auth, Spark)뿐이며, Cloud Run 두 개는 **링크로만 이어진 별도 프로젝트**다(`ARCHITECTURE.md` §6) — 실제 사용량과 예산 알림 설정은 그쪽 프로젝트에서 확인해야 한다. 다만 **결제 계정이 같은 Google 계정 하나에 묶여 있어**(§4) 청구는 함께 온다.

### 개연성 2순위 — Firebase 무료 한도 (낙서장)

낙서장은 **조회(read)가 누구에게나 열려 있어** 방문자가 늘면 읽기 요청이 그대로 늘어난다. 다만 현재 **Spark(무료) 요금제**이므로 한도를 넘으면 청구가 아니라 **그날의 요청이 차단**된다 — 돈보다 "게시판이 조용히 멈춘다"가 실질적인 리스크다.

- 사용 중: Firestore(컬렉션 `graffiti_posts` 1개) + Authentication(이메일/비밀번호 1계정).
- **사용하지 않음**: Cloud Functions·Cloud Storage. `firebase-config.js`에 `storageBucket` 값이 들어 있지만 Storage SDK를 import하는 곳은 없다. 즉 **Blaze로 올려야 할 이유가 아직 없다.**
- Blaze로 전환하면 그 순간부터 초과분이 과금되므로, **전환은 필요해질 때만** 한다.

### 개연성 3순위 — GitHub Pages

public 저장소라 무료다. 다만 Pages에는 사이트 용량·월 전송량·시간당 빌드 횟수의 소프트 리밋이 있고, **저장소를 비공개로 바꾸면 Pages 사용에 유료 플랜이 필요해진다.** 현재 `assets/image/`에 재크롭용 원본 PNG ~42MB가 들어 있어 용량이 계속 늘면 이 리밋을 먼저 만나게 된다.

### 비용 없음

Google Forms, 그리고 CDN 4종(계정·과금 모두 없음).

## 4. 비용은 아니지만 같이 봐야 할 리스크

- **무료 공개 CDN 의존** — Tailwind Play CDN·jsDelivr·unpkg·gstatic 중 하나라도 장애가 나면 그 페이지의 스타일/기능이 즉시 깨진다. 특히 Tailwind Play CDN은 공식적으로 프로덕션 권장 대상이 아니다(빌드 도구를 두지 않기로 한 결정의 트레이드오프 — `DEV_PLAN.md` §1).
- **계정 정리가 진행 중이라 상태가 섞여 있다** — 프로젝트마다 옛 계정과 새 계정이 함께 Owner로 남아 있는 구간이 있다(§2-1). 정리가 끝나기 전에는 "어느 계정을 잃으면 무엇이 끊기는가"를 이 문서만 보고 판단할 수 없다 — §2-1의 확인 명령으로 그때그때 조회한다.
- **1:1 상담 Google Forms는 여전히 `triwon20@gmail.com` 소유다.** Firebase 권한 이전과 전혀 다른 절차이고, 이 계정을 정리할 때 함께 옮기지 않으면 상담 접수가 끊긴다.
- **`firestore.rules`는 수동 게시** — 콘솔에 직접 붙여넣어야 반영된다. 규칙이 느슨해지면 무료 한도 소진이 아니라 무단 쓰기로 이어질 수 있다.

## 5. 갱신 원칙

- 새 외부 서비스를 도입하거나(호스팅·백엔드·유료 API 등), 요금제를 바꾸거나(Spark→Blaze 등), 서브도메인이 새로 오픈되면 이 문서를 함께 갱신한다.
- **구체적 금액·요금제 수치는 적지 않는다** — 바뀌면 곧바로 틀린 문서가 되므로, "어떤 조건에서 과금으로 넘어가는가"만 유지한다.
- 계정 자격 증명(비밀번호·API 키 등)은 이 문서에 적지 않는다.
