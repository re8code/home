# 2026-09-11 — GNB 서브 서비스 라벨을 서비스 설명형으로 교체

## 체크리스트

- [x] 사용자 제안(`Online Judge|Studio|VOD|Business`) 검토 — Studio만 설명력이 약하다고 의견, 대안 논의 후 **Class** 채택
- [x] `partials/header.html` 8곳(데스크톱 nav 4 + 모바일 메뉴 4) 라벨 교체 — href·`target`·"준비중" 배지 마크업 불변
- [x] `./scripts/build-partials.py` → 30장 반영, 옛 라벨(`wonoj`/`studio`/`LMS`/`business`) 잔존 0건
- [x] `check-device.sh --quick` 통과 — "GNB 준비중" 검사가 `VOD`를 보고(패턴 기반이라 스크립트 수정 불필요)
- [x] CDP 실측(1024/1100/1280px): nav 폭 419px, 링크 높이 최대 26px(한 줄), 헤더 오버플로 없음
- [x] 문서 갱신 — `CLAUDE.md` GNB 항목 · `PRD` §3 · `ARCHITECTURE` §6 · `DEV_PLAN` Phase 3 · `DEVLOG`

## 결정 근거

| 종전 | 신규 | 이유 |
| --- | --- | --- |
| wonoj | **Online Judge** | "won의 OJ"라는 내부 이름. 두 단어라 가장 넓지만 1024px에서 여유 확인. "OJ" 축약은 초심자에게 불친절해 풀네임. |
| studio | **Class** | 저장소명(`recodemate`) 유래. 사용자 초안 "Studio"는 여전히 뭘 하는 곳인지 안 보여, 오프라인 수업 예약·수강권 관리를 드러내는 한 단어로. Classroom(길고 공간 느낌)·Lesson(1회 수업 단위)·Booking(예약 기능만) 대비 **VOD와 "오프라인/온라인 수업" 짝**이 되는 Class가 가장 무난. |
| LMS 준비중 | **VOD** 준비중 | LMS는 운영자 용어, 학생 눈높이에선 VOD(인강)가 바로 읽힘. |
| business | **Business** | 기업 의뢰 대상이라 대문자 브랜드명으로 자연스러움. |

한글 항목(회사 소개/원장님의 낙서/1:1 상담 신청)과 영문 4개의 혼용은 "서브 서비스 = 영문 브랜드명" 구분으로 의도된 것.

## 남은 것

- (해소) v0.94·v0.95를 함께 `main`에 병합해 재배포 — Pages 빌드 성공, 라이브 반영 확인(v0.96 기록). 앞선 "Upload artifact" 실패는 일시 장애였다.
