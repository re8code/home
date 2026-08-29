# ACCOUNT_COST.md — 계정·비용 요약

`ARCHITECTURE.md` §1 기술 스택(및 §3 배포·§5 백엔드·§6 서브도메인)에서 **계정이 필요한 항목**과 **비용이 발생할 개연성이 있는 항목**만 뽑아 정리한다. 구조 설명은 `ARCHITECTURE.md`가 정본이고, 이 문서는 "누구 계정으로 무엇이 돌아가고, 어디서 돈이 샐 수 있는가"만 다룬다.

- 최종 갱신: 2026-08-29 (Firebase 콘솔 계정을 `triwon20@gmail.com`으로 정정 — 낙서장 쓰기 계정 `won@re8code.com`과 구분. 신설 — 같은 날 `CLAUDE.md` 제1원칙 문서 세트에 편입되어 7개 문서 중 하나가 됨)
- 확인 방법: 저장소 내 외부 호스트 전수 조사 + 실서비스 응답 헤더/DNS 조회
- **금액은 적지 않는다** — 요금제는 수시로 바뀌므로 각 서비스 콘솔의 값이 정본이다. 여기에는 "과금으로 전환되는 조건"만 적는다.

## 1. 한눈에 보기

| 항목 | 계정 | 현재 비용 | 과금 전환 조건 |
| --- | --- | --- | --- |
| 도메인 `recode.ai.kr` (닷홈) | 닷홈 | **유료(연 단위)** | 이미 발생 중 — 갱신 실패 시 도메인 상실 |
| GitHub + GitHub Pages | GitHub `re8code` | 무료 | 저장소를 **비공개로 전환**하면 Pages에 유료 플랜 필요 |
| Firebase (Firestore + Auth) | Google `triwon20@gmail.com` (콘솔 소유) | 무료(Spark) | 무료 한도 초과 시 **차단**(Spark는 자동 과금 없음). Blaze로 올리면 과금 시작 |
| Google Forms (1:1 상담) | Google (소유 계정 미확인) | 무료 | 사실상 없음 (Drive 용량 한도만) |
| CDN 4종 (Tailwind·jsDelivr·unpkg·gstatic) | 계정 불필요 | 무료 | 없음 — 대신 **가용성 리스크** (§4) |
| `oj.recode.ai.kr` / `mate.recode.ai.kr` | Google Cloud | **결제 계정 연결 필수** | 이 생태계에서 **과금 개연성 1순위** (§3) |
| `business-1e563.web.app` | Google (Firebase) | 무료(Spark) | 호스팅 전송량/용량 한도 초과 시 |
| `lms.recode.ai.kr` | 미정 | 없음 | 오픈 시 호스팅 방식에 따라 결정 |

## 2. 계정이 필요한 항목

이 저장소를 운영하는 데 **반드시 있어야 하는 계정은 3개**다.

1. **닷홈** — 도메인 `recode.ai.kr` 등록·DNS. 네임서버가 `ns1~3.dothome.co.kr`로 확인됨. GitHub Pages와 4개 서브도메인의 A/CNAME 레코드가 전부 여기 걸려 있어, **이 계정을 잃으면 사이트와 서브도메인이 한꺼번에 끊긴다.**
2. **GitHub (`re8code`)** — 저장소 `re8code/home` + GitHub Pages 배포. 저장소는 **public**이라 Pages가 무료다.
3. **Google (`triwon20@gmail.com`)** — Firebase 프로젝트 `graffiti-3b1fc`(Firestore + Authentication)를 소유한 콘솔 계정. `firestore.rules` 게시·요금제 변경·Auth 사용자 관리가 전부 이 계정에서 이뤄진다.

   **주의 — 콘솔 계정과 낙서장 쓰기 계정은 다른 것이다.** `firebase-config.js`의 `ADMIN_EMAIL`과 `firestore.rules`에 박힌 `won@re8code.com`은 Firebase **Authentication에 등록된 사용자**(낙서장의 유일한 쓰기 권한자)이지 프로젝트 소유 계정이 아니다. 둘을 같은 것으로 적어두면 "콘솔에 로그인이 안 된다"는 상황에서 엉뚱한 계정을 찾게 된다.

   1:1 상담 Google Forms가 어느 계정 소유인지는 아직 확인되지 않았다(응답이 쌓이는 곳이라 확인 필요).

계정이 **필요 없는** 것: Tailwind Play CDN·jsDelivr(Pretendard, Swiper)·unpkg(AOS)·gstatic(Firebase SDK) — 전부 익명 공개 CDN이다.

## 3. 비용 발생 개연성

### 확정적으로 나가는 돈 — 도메인뿐

현재 **정기적으로 결제되는 것은 `recode.ai.kr` 도메인 갱신 하나**다. 나머지는 전부 무료 한도 안에서 돌고 있다.

### 개연성 1순위 — Google Cloud (서브도메인 2개)

`oj.recode.ai.kr`·`mate.recode.ai.kr` 둘 다 응답 헤더가 `server: Google Frontend`이고, studio는 원래 `recodemate-...-du.a.run.app`(Cloud Run) 주소로 연결했던 이력이 있다. **Cloud Run은 결제 계정이 연결돼 있어야 동작**하므로, 무료 한도를 넘는 순간 별도 확인 없이 청구된다 — 이 생태계에서 실제로 돈이 샐 가능성이 가장 높은 지점이다.

다만 **두 서비스 모두 이 저장소가 아니라 별도 프로젝트에서 관리**하므로(`ARCHITECTURE.md` §6), 실제 사용량·예산 알림 설정은 해당 프로젝트 쪽에서 확인해야 한다. 이 저장소가 하는 일은 링크 연결뿐이다.

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
- **단일 Google 계정 집중** — Firebase·Forms·(서브도메인의) Google Cloud가 모두 한 계정에 묶여 있다. 계정 하나가 잠기면 낙서장·상담 접수·서브도메인이 동시에 영향을 받는다.
- **`firestore.rules`는 수동 게시** — 콘솔에 직접 붙여넣어야 반영된다. 규칙이 느슨해지면 무료 한도 소진이 아니라 무단 쓰기로 이어질 수 있다.

## 5. 갱신 원칙

- 새 외부 서비스를 도입하거나(호스팅·백엔드·유료 API 등), 요금제를 바꾸거나(Spark→Blaze 등), 서브도메인이 새로 오픈되면 이 문서를 함께 갱신한다.
- **구체적 금액·요금제 수치는 적지 않는다** — 바뀌면 곧바로 틀린 문서가 되므로, "어떤 조건에서 과금으로 넘어가는가"만 유지한다.
- 계정 자격 증명(비밀번호·API 키 등)은 이 문서에 적지 않는다.
