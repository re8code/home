# 네비게이션 바 위치 불일치 해결

## 목적
UI 통일성 유지 — index.html과 나머지 페이지의 상단 네비게이션 바 항목 위치를 일치시킴 (tasks/nav-position.md)

## 원인
헤더의 `<div class="mx-auto max-w-7xl px-6 lg:px-8 h-16 flex items-center justify-between">`는 로고 / nav / 우측 그룹 3개의 flex 자식을 `justify-between`으로 배치하는 구조. `index.html`의 우측 그룹에는 "원장님의 낙서" 링크 + "1:1 상담 신청" 버튼이 있었지만, `graffiti.html`, `graffiti-detail.html`, `graffiti-new.html` 3개 페이지의 우측 그룹에는 "원장님의 낙서" 링크가 빠져 있었음.

`justify-between` 레이아웃에서는 우측 그룹의 콘텐츠 너비가 전체 배치에 영향을 주기 때문에, 그룹 너비가 페이지마다 달라 nav(철학/훈련 과정/대상) 항목의 x축 위치가 페이지 이동 시마다 어긋나는 현상이 발생했음.

- 실측(뷰포트 1720px 기준): index.html의 `nav.left = 755.64px` vs 나머지 3개 페이지 `nav.left = 803.65px` (약 48px 어긋남)

## 수정 내용 (1차)
`graffiti.html`, `graffiti-detail.html`, `graffiti-new.html` 3개 파일의 헤더에 index.html과 동일하게 "원장님의 낙서" 링크를 실제 기능 링크로 추가하여 우측 그룹 너비를 맞춤.

## 수정 내용 (2차 — 사용자 피드백 반영)
1차 방식은 다른 페이지에서도 "원장님의 낙서"·"1:1 상담 신청"이 실제로 노출/동작하게 되는 부작용이 있어, 아래와 같이 변경:
- **index.html**: 두 항목 그대로 노출 및 정상 동작(기존과 동일)
- **그 외 3개 페이지(데스크톱 nav)**: `<a>` 대신 `<span aria-hidden="true">`로 교체하고 `invisible pointer-events-none select-none` 클래스 적용. `visibility: hidden`이라 레이아웃 박스(자리)는 그대로 유지되어 nav 위치는 index.html과 계속 일치하지만, 화면에 보이지 않고 클릭/포커스도 불가능(완전 비활성).
- **그 외 3개 페이지(모바일 드롭다운)**: 두 항목을 아예 제거(철학/훈련 과정/대상 3개만 노출). 모바일 드롭다운은 세로 스택 레이아웃이라 자리 유지가 위치 정합성에 영향을 주지 않으므로, 자리 보전 없이 완전히 뺌.

## 검증
claude-in-chrome으로 로컬 정적 서버(`python3 -m http.server 8765`) 기동 후 확인:
- 4개 페이지 모두 데스크톱 뷰포트(1720px)에서 `header nav`의 `getBoundingClientRect().left` 값이 `755.64px`로 완전히 일치함을 JS로 실측 확인
- index.html: "원장님의 낙서"/"1:1 상담 신청" 정상 노출·클릭 가능 확인
- 그 외 3개 페이지: 두 항목이 `visibility: hidden`, `pointer-events: none`으로 비활성 처리되어 화면에 보이지 않음을 JS(getComputedStyle)로 확인
- 작업에 사용한 브라우저 탭은 모두 close 처리

## 참고
- 브라우저 자동화 도구의 창 크기 조절이 즉시 반영되지 않는 경우가 있어, 좌표 실측은 desktop 뷰포트에서 진행함 (모바일 토글 동작 자체는 이전 작업(2026-07-30-mobile-menu-fix.md)에서 이미 검증됨).
