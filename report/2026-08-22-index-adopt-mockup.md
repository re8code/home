# index.html에 mockup.html 콘텐츠 흡수 · mockup.html 삭제 보고서

- 작성일: 2026-08-22
- 작업 대상: `index.html` 전면 교체, `src/mockup.html` 삭제, 연쇄적으로 깨지는 내부 링크 수정

## 1. 배경

`src/mockup.html`은 원래 "Epic Games Store 레이아웃을 참고한 훈련 코스 페이지 목업"으로, `index.html`(실제 랜딩 페이지)과는 분리된 검토용 파일이었다. `PRD.md` §8에는 "라이트 톤 시안을 사용자가 보고 최종 결정 예정 — 다크 톤 유지로 되돌아갈 가능성도 열려 있음"이라는 미결 사항으로 남아 있었다.

사용자가 "`src/mockup.html`의 내용을 모두 `index.html`로 옮기고 `mockup.html`은 제거한다"고 명시적으로 지시 — 이는 그 미결 사항에 대한 최종 결정으로, `mockup.html`의 라이트 톤·코스 카탈로그 구성을 `index.html`의 최종안으로 채택하는 것과 같다.

## 2. 콘텐츠 교체 (전면 교체, 병합 아님)

지시가 "모두 옮기고 제거한다"였으므로, 기존 `index.html`(다크 인디고 톤, 문제의식/핵심철학/훈련프로세스/대상/CTA 섹션)을 `mockup.html`의 전체 콘텐츠로 **완전히 교체**했다. 두 파일 모두 자체적인 "핵심 철학"·"CTA" 섹션을 갖고 있어 병합하면 중복이 생기는 구조였다는 점도 전면 교체가 맞다는 판단을 뒷받침한다.

**결과적으로 사라진 것**: 기존 `index.html`의 "왜 우리는 학원이길 거부하는가"(문제의식 비교), "훈련 프로세스"(`#process`, STEP 1~4), "대상"(`#who`, 대학생 타겟 설명) 3개 섹션. 이 콘텐츠는 이번 교체로 완전히 제거됐다 — 필요하면 git 이력(`git log -p -- index.html`)에서 복구 가능.

**옮기며 정리한 것** (mockup 특유의 "검토용" 표식 제거):
- 상단 amber색 "MOCKUP — Epic Games Store 레이아웃 참고 재구성 · 실제 페이지와 연결되지 않음" 안내 배너 삭제.
- `<title>`을 `[MOCKUP] 훈련 코스 — Recode Coding` → `Recode Coding — AI시대, 신입 시니어를 훈련하다`(기존 index.html의 SEO 타이틀)로 되돌림.
- `<meta name="robots" content="noindex, nofollow">` 제거(검색엔진 색인 차단 해제).
- 하단 "도구 검토 노트"(Swiper/AOS/Epic Games Store 벤치마크에 대한 개발자용 메모 섹션) 삭제 — 실 방문자에게 노출될 이유가 없는 내부 검토 기록이었음.
- 푸터 최하단 문구 `MOCKUP · 훈련 코스 페이지 스케치 ... 실제 서비스 페이지 아님` → `© 2026 Recode Coding. AI시대 프로그래밍 연구소.`(기존 index.html 카피라이트 표기)로 교체.

## 3. 경로 수정 (src/ → 루트로 위치가 바뀌며 필요)

`mockup.html`은 `src/`에 있었고 `index.html`은 저장소 루트에 있으므로, 내용을 옮기며 상대 경로를 모두 반전시켰다:
- `src="../assets/..."` → `src="assets/..."` (이미지 5개, `mobile-menu.js`)
- `href="../index.html"`(자기 자신을 가리키던 로고 링크) → `href="#"`(기존 index.html 관례)
- `href="graffiti.html"` → `href="src/graffiti.html"` (헤더 nav, 데스크톱·모바일 각 1곳)
- `href="lang-cp.html"`(C/C++ 카드) → `href="src/lang-cp.html"`
- 헤더 `sticky top-[26px]` → `sticky top-0`, 서브바 `sticky top-[90px]` → `sticky top-16` (MOCKUP 배너 제거로 오프셋이 필요 없어짐)

## 4. 연쇄 링크 수정

`mockup.html`을 가리키던 다른 페이지들도 함께 고쳐야 링크가 죽지 않는다:

- **`src/lang-cp.html`**: `href="mockup.html#lang"` 등 8곳을 `href="../index.html#lang"`(및 `#algo`/`#web`/`#game`/`#agent-ai`/`#philosophy`/`#cta`)로 일괄 치환.
- **`src/graffiti.html` / `src/graffiti-detail.html` / `src/graffiti-new.html`**: 이 3개 파일의 헤더 nav는 옛 `index.html`의 `#process`(훈련 과정)·`#who`(대상) 섹션을 가리키고 있었는데, 새 `index.html`에는 그 두 섹션이 없어 죽은 링크가 된다. `#philosophy`(철학)는 새 `index.html`에도 그대로 있어 유지하고, `#process`/`#who` 2개 링크는 제거·통합했다:
  - "훈련 과정"(`#process`) → "훈련 코스"(`#lang`)로 라벨·링크 교체(`lang-cp.html` 헤더의 "훈련 코스" 표기와 통일).
  - "대상"(`#who`) → 대응하는 섹션이 없어 링크 자체를 삭제.

## 5. 검증 (클로드 인 크롬, `localhost:8765`)

- `index.html` 로드: MOCKUP 배너 없음, 콘솔 에러 없음, Language 카드 5개 로고 이미지(`assets/image/*.png`) 정상 표시.
- `index.html` → C/C++ 카드 클릭 → `src/lang-cp.html` 정상 이동.
- `src/lang-cp.html` → "훈련 코스" 링크 클릭 → `index.html#lang`로 정상 복귀, 히어로 사이드 리스트의 Language 탭이 활성 상태로 전환.
- `src/graffiti.html` 직접 접속: 헤더 nav가 "철학"/"훈련 코스" 두 개로 정상 표시(죽은 링크 없음), Firestore 목록 정상 로드, 콘솔 에러 없음.

## 6. 후속 고려사항

- `graffiti*.html`의 헤더는 여전히 `DEV_PLAN.md` Phase 2("낙서장 톤 조정")가 착수되지 않아 예전 다크 스타일 그대로다 — 이번 작업은 죽은 링크만 고쳤을 뿐, 시각적 톤은 손대지 않았다.
- 기존 `index.html`의 문제의식/훈련 프로세스/대상 콘텐츠가 완전히 사라진 것이 의도와 다르다면 git 이력에서 복구하거나 필요한 부분만 새 `index.html`에 다시 추가하면 된다.
