# Recode Coding 홈페이지 배포 방법 보고서

- 작성일: 2026-07-29
- 배포 대상: `./index.html` (랜딩 페이지)
- 배포 방식: GitHub Pages
- 커스텀 도메인: dothome.co.kr에서 구입한 도메인 연결
- GitHub 저장소: `git@github.com:re8code/home.git` (이미 원격 저장소로 연결됨, 아직 커밋 없음)

## 1. 현재 상태 확인

- 로컬 저장소는 `origin`이 `re8code/home` GitHub 저장소로 이미 연결되어 있으나,
  아직 커밋된 이력이 없음(`git log` 비어 있음)
- `index.html`이 저장소 루트에 위치 → GitHub Pages의 "루트(`/`) 배포" 방식과 바로 호환됨
- 저장소 이름이 `home`이므로(사용자명.github.io 형식이 아님), 커스텀 도메인을 연결하지
  않을 경우 기본 접속 주소는 `https://re8code.github.io/home/` 형태가 됨

## 2. 배포 절차 (순차)

### Step 1. 로컬 변경 사항 커밋 & GitHub 푸시 (사용자 승인 후 진행)
```bash
git add index.html CLAUDE.md task.md report/
git commit -m "Initial commit: Recode Coding landing page"
git push -u origin main
```
- 저장소가 비공개(private)든 공개(public)든 GitHub Pages 사용 가능(Private는 GitHub Pro
  이상 플랜 필요할 수 있음 → 저장소를 Public으로 두는 것을 권장)

### Step 2. GitHub Pages 활성화
1. GitHub 저장소(`re8code/home`) → **Settings** → **Pages** 메뉴 진입
2. **Build and deployment → Source**: `Deploy from a branch` 선택
3. **Branch**: `main` / 폴더는 `/ (root)` 선택 후 저장
4. 저장 후 몇 분 내 `https://re8code.github.io/home/` 로 사이트가 자동 배포됨

### Step 3. 기본 배포 URL 접속 확인
- `https://re8code.github.io/home/` 접속 → 랜딩 페이지가 정상 노출되는지 확인
- 이 단계에서 정상 동작을 먼저 확인한 뒤 커스텀 도메인 연결을 진행하는 것을 권장
  (커스텀 도메인 이슈와 배포 이슈를 분리해서 디버깅하기 위함)

### Step 4. 커스텀 도메인 연결 준비 — `CNAME` 파일 생성
- 저장소 루트에 `CNAME`이라는 이름의 파일을 만들고, 사용할 도메인 한 줄만 기재
  - 예) apex 도메인 사용 시: `dothome.co.kr`
  - 예) www 서브도메인 사용 시: `www.dothome.co.kr`
- 이 파일은 Step 6에서 GitHub Pages 설정 화면에 도메인을 입력하면 자동 생성/커밋되므로,
  수동 생성 대신 Step 6에서 한 번에 처리해도 무방함

### Step 5. dothome.co.kr DNS 설정 (사용자 작업 — dothome 관리 콘솔에서 진행)
dothome 호스팅/도메인 관리 콘솔의 "DNS 설정" 메뉴에서 아래 중 하나를 선택해 설정합니다.

**옵션 A. apex 도메인(`dothome.co.kr`)을 그대로 사용하는 경우 — A 레코드 4개 등록**

| 타입 | 호스트 | 값(IP) |
| --- | --- | --- |
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |

(선택) IPv6도 함께 등록하려면 AAAA 레코드 4개 추가:
`2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153`

**옵션 B. `www` 서브도메인을 사용하는 경우 — CNAME 레코드 1개 등록**

| 타입 | 호스트 | 값 |
| --- | --- | --- |
| CNAME | www | re8code.github.io |

→ 둘 중 하나만 선택하면 되며, 보통 apex(A 레코드) + `www`(CNAME, 리다이렉트용)를
함께 등록해 두 주소 모두 접속되게 하는 구성을 많이 사용함

### Step 6. GitHub 저장소에 커스텀 도메인 등록
1. **Settings → Pages → Custom domain**에 dothome에서 결정한 도메인 입력
   (예: `dothome.co.kr` 또는 `www.dothome.co.kr`) 후 **Save**
2. GitHub가 DNS 확인(Check DNS) 후 자동으로 저장소 루트에 `CNAME` 파일 생성
3. DNS가 정상 인식되면 **Enforce HTTPS** 체크박스가 활성화됨 → 반드시 체크
   (Let's Encrypt 인증서가 자동 발급되며, 발급까지 최대 24시간 소요될 수 있음)

### Step 7. DNS 전파 대기 및 검증
- DNS 변경은 즉시 반영되지 않고 통상 수분~48시간까지 전파 시간이 걸릴 수 있음
- 아래 명령으로 전파 여부 확인 가능
```bash
dig dothome.co.kr +noall +answer
# 또는
nslookup dothome.co.kr
```
- A 레코드가 위 GitHub IP 4개로 정상 조회되면 전파 완료

### Step 8. 최종 접속 확인
- `https://dothome.co.kr` (또는 `https://www.dothome.co.kr`) 접속 → 랜딩 페이지 정상
  노출 및 자물쇠(HTTPS 인증서) 표시 확인
- Google Forms 연동 버튼 등 기존 기능이 실제 배포 도메인에서도 정상 동작하는지 재확인
  (`./report/2026-07-29-google-forms-consultation-plan.md` Step 7과 연계)

## 3. 역할 구분 요약

| 단계 | 수행 주체 |
| --- | --- |
| Step 1 (커밋/푸시) | 사용자 승인 후 Claude 진행 가능 |
| Step 2~3 (Pages 활성화, 1차 확인) | 사용자 (GitHub 웹 UI 조작) |
| Step 4 (CNAME 파일) | Claude 또는 Step 6에서 GitHub가 자동 처리 |
| Step 5 (dothome DNS 설정) | 사용자 (dothome 계정 로그인 필요) |
| Step 6 (Custom domain 등록) | 사용자 (GitHub 웹 UI 조작) |
| Step 7~8 (전파 대기·최종 검증) | 공동 |

## 4. 주의 사항

- GitHub Pages는 정적 사이트만 지원 — 현재 구조(단일 `index.html` + Tailwind CDN)는
  별도 빌드 없이 그대로 호환됨
- 저장소를 Private로 유지할 경우 GitHub Pages 사용 가능 여부가 플랜에 따라 다르므로,
  홍보용 랜딩 페이지 목적상 Public 저장소 권장
- DNS 전파 중에는 일시적으로 접속이 안 되거나 인증서 경고가 뜰 수 있음 — 정상적인
  현상이며 전파 완료 후 자동 해소됨

## 5. 다음 액션

1. Step 1 진행(커밋/푸시) 여부를 확인해 주시면 바로 진행하겠습니다.
2. dothome.co.kr에서 apex 도메인 / `www` 서브도메인 중 어떤 것을 사용할지 결정해 주시면
   Step 5 DNS 설정값을 확정해 안내하겠습니다.
