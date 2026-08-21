# mockup.html 히어로 1번째 레이어 개선

## 목적
`tasks/task-layer-01.md` 3개 항목 반영:
1. 우측 5개 카테고리 버튼 높이를 동일하게 맞추고, 5개 버튼 높이 합을 좌측 메인 배너 높이와 일치
2. 게이지가 완성되어 다음 슬라이드로 넘어갈 때 좌측 콘텐츠가 슬라이딩되는 전환 애니메이션 추가 (Epic Games Store 벤치마크 참고)
3. 게이지 속도를 6초 → 3초로 조정

## 수정 내용 (`mockup.html`)
1. **버튼 높이 동일화**: `#hero-side-list`에 `h-full` 추가, 5개 `.side-item` 버튼에 `flex-1 justify-center`를 적용. 그리드(`lg:grid-cols-[1fr_320px]`)의 기본 `align-items: stretch`로 사이드 리스트가 이미 배너 높이(`min-h-[440px]`)만큼 늘어나 있었으므로, 버튼을 `flex-1`로 바꿔 그 안에서 5개가 동일한 높이로 균등 분배되도록 함.
2. **슬라이드 전환 애니메이션**: 배너의 텍스트/CTA 오버레이(`<div id="hero-content">`)에 `heroSlideOut`(좌측으로 -32px 이동 + 페이드 아웃) → 콘텐츠 교체 → `heroSlideIn`(우측 +32px에서 원위치로 페이드 인) 키프레임 2개를 추가. `activateSlide()`를 `applySlideContent()`(텍스트/블롭 갱신)와 분리하고, 클릭·자동 전환 시에는 280ms 아웃 애니메이션 후(`CONTENT_SWAP_MS = 260ms` 시점) 텍스트를 교체하고 320ms 인 애니메이션을 재생하도록 `setTimeout` + 강제 리플로우로 구성. 최초 로드시(`activateSlide(0, { skipAnimation: true })`)에는 애니메이션 없이 즉시 표시.
3. **게이지 속도**: `DURATION` 상수를 `6000` → `3000`으로 변경 (자동 전환 주기 및 게이지 채움 속도에 동일하게 적용, 기존 `[data-gauge]` 애니메이션 로직은 변경 없이 재사용됨).

## 검증
클로드 인 크롬으로 로컬 서버(`localhost:8765/mockup.html`) 확인:
- 초기 로드 시 5개 버튼 높이가 배너 높이에 맞춰 균등하게 채워짐을 스크린샷으로 확인.
- 사이드 항목 클릭(Web & WebApp) 시 즉시 활성 전환되고, 배너 텍스트가 슬라이드 아웃/인 애니메이션 도중(옅어진 상태)으로 캡처되어 전환 효과가 실제로 걸리고 있음을 확인.
- 자동 재생도 3초 주기로 여러 차례 슬라이드가 넘어가는 것을 확인(도구 호출 왕복 지연으로 정확한 프레임 단위 관찰은 어려웠으나 정상 동작 확인).
- 콘솔 에러 없음(`read_console_messages`, onlyErrors 필터).

## 참고
- `index.html`은 이번 작업 범위에 포함되지 않음(히어로 레이어는 `mockup.html`에만 존재).

## 후속 반영: 배경 블롭도 함께 슬라이딩/페이드
텍스트만 슬라이딩되던 것에서, 사각형 배너 안의 배경 블롭(`hero-blob-1/2`)도 텍스트와 함께 하나의 장면으로 슬라이딩/페이드되도록 확장.

- 블롭 2개 + `hero-content`(텍스트)를 `<div id="hero-scene" class="absolute inset-0">`로 묶음. `hero-banner`(둥근 사각 틀, `overflow-hidden`)는 고정된 창 역할만 하고, 그 안의 `hero-scene` 전체가 좌측으로 슬라이드 아웃 → 콘텐츠 교체 → 우측에서 슬라이드 인.
- CSS `is-sliding-out`/`is-sliding-in` 애니메이션 대상을 `#hero-content` → `#hero-scene`으로 이동. JS도 `contentEl` → `sceneEl`로 변경(로직 구조는 동일, 애니메이션 대상만 확장).
- 블롭 자체의 색상 전환(`transition-colors duration-700`)은 그대로 유지되어, 위치 슬라이딩과 색상 크로스페이드가 동시에 일어남.
- 클로드 인 크롬으로 확인: 전환 중간 프레임에서 블롭 배경과 텍스트가 함께 옅어지며 이동하는 것을 스크린샷으로 확인, 콘솔 에러 없음.
