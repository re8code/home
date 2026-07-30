# 모바일 상단 메뉴 사라짐 문제 해결

## 목적
모바일 브라우저에서 상단 메뉴가 사라지는 현상 해결 (tasks/mobile-menu.md)

## 원인
`index.html`, `graffiti.html`, `graffiti-detail.html`, `graffiti-new.html` 4개 페이지 모두 헤더의 `<nav>`가 `hidden md:flex` 클래스만 적용되어 있었음.

- `md`(768px) 이상: nav가 flex로 표시됨
- `md` 미만(모바일): nav가 `hidden`으로 완전히 숨겨지고, 이를 대체할 햄버거 메뉴 등 모바일 전용 진입점이 전혀 구현되어 있지 않았음

즉, 모바일에서는 로고와 CTA 버튼만 남고 철학/훈련 과정/대상/원장님의 낙서 등 메뉴 항목에 접근할 방법이 없어 "메뉴가 사라진" 것처럼 보이는 상태였음. 헤더 자체는 `fixed top-0`으로 스크롤 시에도 항상 화면에 고정되어 있어, 스크롤에 의해 사라지는 문제는 아니었음.

## 수정 내용
1. `assets/js/mobile-menu.js` 신규 작성 — 햄버거 버튼 클릭 시 모바일 메뉴 패널 열기/닫기, 메뉴 내 링크 클릭 시 자동 닫힘, 아이콘(햄버거 ↔ X) 전환, `aria-expanded` 상태 관리.
2. 4개 페이지(`index.html`, `graffiti.html`, `graffiti-detail.html`, `graffiti-new.html`) 헤더에 공통으로:
   - `md:hidden` 햄버거 버튼 추가 (데스크톱에서는 숨김, 모바일에서만 노출)
   - 데스크톱 전용이던 CTA 버튼(`1:1 상담 신청`)은 모바일에서 숨기고, 대신 드롭다운 메뉴 패널 안에 포함
   - 헤더 하단에 `#mobile-menu` 드롭다운 패널 추가 (철학 / 훈련 과정 / 대상 / (index만) 원장님의 낙서 / 1:1 상담 신청)
   - `</body>` 직전에 `<script src="assets/js/mobile-menu.js" defer></script>` 추가

## 검증
claude-in-chrome으로 로컬 정적 서버(`python3 -m http.server`) 기동 후 모바일 뷰포트(약 500px 폭)에서 4개 페이지 모두 확인:
- 햄버거 아이콘이 헤더에 정상 노출됨
- 클릭 시 메뉴 패널이 열리고 아이콘이 X로 전환됨
- 메뉴 내 링크(`#philosophy`) 클릭 시 해당 섹션으로 이동하며 메뉴가 자동으로 닫힘
- 스크롤 시에도 헤더가 화면 상단에 고정되어 계속 노출됨(fixed 헤더 정상 동작)

## 참고
- 브라우저 자동화 도구의 창 크기 조절이 즉시 반영되지 않는 경우가 있어, 캐시 무효화를 위한 재탐색(navigate) 후 뷰포트 크기 변경을 확인해야 했음.
- 실제 기기(iOS Safari 등)에서의 최종 확인은 별도로 권장.
