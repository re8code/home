# index.html Web & WebApp 섹션 카드 재구성 (4장 → 5장, 커스텀 아이콘 + 정적 그리드)

## 목적
Web & WebApp 코스 상세 페이지 제작에 앞서, 대화로 흐름을 4단계(프론트/백엔드/DevOps/CI-CD)로 정리한 뒤 사용자 제안으로 기존 "Full-stack 프로젝트" 캡스톤 카드를 유지해 5장으로 확정. 커버아트도 추상적인 텍스트 배지(FE/BE/FS/Ops) 대신 더 직관적인 이미지로 교체.

## 카드 구성 변경
- 기존 4장: Frontend 기초(React) / Backend(Node·Spring) / Full-stack 프로젝트 / 배포·인프라 기초(Ops, CI/CD 포함)
- 신규 5장: **Frontend(React)** → **Backend(Node/Spring)** → **DevOps(Docker)** → **CI/CD(GitHub Actions)** → **Full-stack 통합 프로젝트**(캡스톤, 마지막 카드 하이라이트 적용)
- 기존 "배포/인프라 기초" 한 장에 뭉쳐 있던 DevOps·CI/CD 설명을 두 장으로 분리해 각각의 설명 문구를 새로 작성.

## 커버아트 이미지 소스
Unsplash 등 사진 스톡은 검토했으나, 사이트 전반의 "그라디언트 배경 + 크리스프한 심볼" 톤(Language 섹션의 실제 로고, Algorithm 섹션의 커스텀 SVG)과 어울리지 않는다고 판단해 제외 — Language 카드와 동일하게 **실제 기술 로고**를 카드 설명에 언급된 대표 기술에 맞춰 매칭.

- **React / Node.js / Docker / GitHub Actions**: devicon(MIT 라이선스, `github.com/devicons/devicon`) 저장소의 `*-original.svg`(컬러 아이콘 단독 버전, 128×128 viewBox)를 `jsdelivr` CDN에서 직접 다운로드 — `assets/image/react.svg`, `nodejs.svg`, `docker.svg`, `github-actions.svg`로 저장. Java/Python/Dart 워드마크를 가져올 때와 동일한 저장소·라이선스(2026-08-22 선례, `report/2026-08-22-mockup-language-layer-02.md` 참고)이지만, 이번엔 SVG를 PNG로 변환할 필요 없이 원본 SVG를 그대로 `<img>`로 사용(당시엔 로컬 래스터화 도구가 없어 wsrv.nl 프록시로 PNG 변환했었음 — 이번엔 SVG 그대로도 문제없어 그 단계 생략).
- **Full-stack 통합 프로젝트**: 단일 브랜드가 없는 카드라 실제 로고 대신 커스텀 인라인 SVG(가로 막대 3개가 위→아래로 화살표로 이어지는 형태, 불투명도로 계층 구분)를 새로 그려 "프론트·백엔드·인프라가 하나로 엮인다"는 개념을 표현 — Algorithm 섹션의 커스텀 아이콘과 동일한 제작 방식.

## 검증 (1차)
- `assets/image/*.svg` 4개 파일 다운로드 후 `content-type: image/svg+xml`, HTTP 200 확인.
- `index.html` HTML 태그 밸런스 검사(Python `html.parser`) 통과.
- 로컬 서버로 `index.html`·4개 이미지 파일 전부 200 응답 확인.
- claude-in-chrome MCP 연결이 끊긴 상태라 실제 브라우저 렌더링(카드 배치·이미지 시각 확인)은 수행하지 못함 — 연결 복구 시 확인 필요.

## 후속 수정 (같은 날, 사용자 피드백 3건)
1차 결과를 공유하자 사용자가 세 가지를 지시:
1. 커버아트 색상을 JS 대표 색상인 노란색으로 통일.
2. "카드 상단 영역을 가득 채우는 형태의 이미지"가 가능한지 질의.
3. 카드가 5장뿐이므로 Swiper 캐러셀 없이 Language 섹션처럼 정적 그리드로.

대응:
- **색상**: 5개 카드 커버아트를 `--from:#7dd3fc;--to:#075985`(하늘색)에서 `--from:#fde047;--to:#854d0e`(Tailwind yellow-300~yellow-800)로 변경.
- **가득 채우는 이미지**: `h-20 w-20` 크기의 실제 로고를 그대로 확대하면 로고 특유의 여백 때문에 어색해지므로, Algorithm/자료구조 섹션에서 이미 쓰고 있던 패턴(`class="absolute inset-0 h-full w-full"`로 커버아트 전체를 채우는 커스텀 인라인 SVG)으로 전환할 것을 역제안하고 실행. 다운로드해둔 로고 SVG 4개는 삭제하지 않고 `assets/image/`에 유지(현재 `index.html`에서는 미사용, 추후 상세 페이지에서 재사용 가능) — 대신 각 기술의 브랜드 색상(React `#61dafb`/Node `#68a063`/Docker `#2496ed`/GitHub Actions `#2088ff`)을 커스텀 아이콘 안의 강조색으로 재사용해 "실제 로고"의 직관성을 일부 유지: Frontend=브라우저 창+React 원자 심볼, Backend=서버 랙↔DB 원통 양방향 화살표, DevOps=컨테이너 3개+톱니바퀴, CI/CD=4단계 파이프라인 노드. Full-stack 통합 프로젝트 아이콘은 기존 것을 그대로 쓰되 강조색만 새 배경에 맞게 갱신.
- **Swiper 제거**: `.course-swiper`/`swiper-slide`/`swiper-pagination`/`swiper-nav-group` 마크업을 전부 제거하고 Language 섹션과 동일한 `grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4 mt-8` 정적 그리드로 교체. Unity/Agent AI 섹션은 여전히 4카드 Swiper 구조라 손대지 않음.

## 검증 (2차)
- `index.html` HTML 태그 밸런스 검사 재통과, Web & WebApp 섹션 내 `swiper` 문자열 0건 확인(완전히 제거됐는지 grep으로 검증).
- 로컬 서버로 `index.html` 200 응답 확인.
- claude-in-chrome MCP 연결이 여전히 끊긴 상태라 이번에도 실제 브라우저 렌더링(그리드 배치·아이콘 시각 확인)은 수행하지 못함 — 연결 복구 시 확인 필요.

## 후속 미세 조정 (같은 날)
- Frontend 카드 React 원자 심볼이 아래쪽 UI 블록 때문에 무게중심이 낮아 보인다는 지적에 따라 `translate(200,172)` → `translate(200,155)`로 17px 위로 이동.
- 5개 카드 전부에서 난이도 배지(입문/중급/심화)를 완전히 제거 — 커버아트가 텍스트 없이 아이콘만으로 구성되도록 정리.

## 다음 단계
5개 카드 상세 페이지(`src/web-frontend.html` 등, 파일명 미정)는 아직 제작하지 않음 — Language 페이지(`lang-cp.html`)류의 12개 커리큘럼 아코디언 카드 형식을 템플릿으로 삼을 예정(대화로 논의한 각 페이지별 주제 목록은 이 리포트에는 남기지 않음, 추후 작업 시 확정).
