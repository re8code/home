#!/usr/bin/env bash
#
# 장비 점검 — docs/CHANGE_DEVICE.md §2(저장소 무결성)·§3(경로 키 상태)·§7(문서 정합성)의 실행판.
#
# 이 스크립트가 존재하는 이유:
#   장비를 옮길 때마다 점검 "결과"(페이지 수, 라이브러리 버전, 링크 건수, 경로 잔재 개수 등)를
#   문서에 적어 남기면 그 값은 다음 장비에서 반드시 어긋나고 또 고치게 된다(핑퐁).
#   그래서 결과는 화면에만 출력하고 저장소에는 남기지 않는다.
#   문서에는 "결정한 것"만 두고, "조회하면 알 수 있는 것"은 여기서 조회한다.
#   → 장비 이동만으로는 커밋이 생기지 않아야 한다. 마지막 "문서 드리프트" 절이 그것을 감시한다.
#
# 판정 기준은 가능한 한 저장소 파일에서 유도한다(HTML 실물 / docs/ARCHITECTURE.md §1 표 /
# .gitignore) — 같은 사실을 문서와 스크립트 양쪽에 적지 않기 위함.
#
# 사용법:
#   ./scripts/check-device.sh          # 전체 (로컬 서버 기동 포함, 수 초)
#   ./scripts/check-device.sh --quick  # 로컬 서버 검사 생략
#   ./scripts/check-device.sh --audit  # 문서 드리프트 감사까지만 (커밋 직전 확인용)
#
# 종료 코드: 실패(❌)가 하나라도 있으면 1, 경고(⚠️)만 있으면 0.

set -uo pipefail
cd "$(dirname "$0")/.."

PORT="${CHECK_DEVICE_PORT:-8799}"   # start.sh 기본 포트(8765)와 겹치지 않게

# 낙서장 쓰기 계정 — ARCHITECTURE.md ADR D4로 고정된 목록.
# 저장소에서 유도할 수 없는 유일한 판정 기준이라 여기 둔다. 바꾸려면 ADR을 먼저 고친다.
# 순서는 무관하다(정렬해 비교한다). 전부 소문자로 적는다.
FIXED_ADMIN_MAILS="triwon20@gmail.com won@re8code.com"

QUICK=0; AUDIT_ONLY=0
case "${1:-}" in
  --quick) QUICK=1 ;;
  --audit) AUDIT_ONLY=1 ;;
esac

FAIL=0; WARN=0
ok()   { printf '✅  %-14s %s\n' "$1" "$2"; }
warn() { printf '⚠️   %-14s %s\n' "$1" "$2"; WARN=$((WARN+1)); }
bad()  { printf '❌  %-14s %s\n' "$1" "$2"; FAIL=$((FAIL+1)); }
hint() { printf '          → %s\n' "$1"; }

PAGES=(index.html src/*.html)
NPAGES=${#PAGES[@]}
# 30개 페이지 전부에 있어야 하는 요소 (라벨|검색 문자열)
COMMON=(
  "tailwind-config|/assets/js/tailwind-config.js"
  "base.css|/assets/css/base.css"
  "favicon|favicon.ico?v="
  "apple-touch-icon|apple-touch-icon"
  "og:title|og:title"
  "og:image|og:image"
  "헤더 로고|image/logo.png"
  "mobile-menu.js|mobile-menu.js"
  "main pt-16|pt-16"
  "GNB lg:flex|hidden lg:flex"
  "GNB lg:hidden|lg:hidden"
  "Pretendard|pretendard"
)

echo "── 도구 ────────────────────────────────────"
for t in python3 git curl; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t" "$($t --version 2>&1 | head -1)"
  else bad "$t" "설치되지 않음 — 이 저장소의 기본 작업에 필요"; fi
done
command -v gh >/dev/null 2>&1 && ok "gh" "설치됨 (Pages 빌드 상태 확인용)" \
  || warn "gh" "없음 — 배포 후 Pages 빌드 상태를 CLI로 못 봄"
if [ -d "/Applications/Google Chrome.app" ] || command -v google-chrome >/dev/null 2>&1; then
  ok "Chrome" "있음 (start.sh 자동 오픈·CDP 뷰포트 검증용)"
else
  warn "Chrome" "없음 — ./start.sh 자동 오픈과 390px CDP 검증 불가"
fi

echo "── 저장소 상태 ─────────────────────────────"
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
[ "$BR" = "dev" ] && ok "브랜치" "dev" || warn "브랜치" "$BR (평소 작업은 dev)"

git fetch -q origin 2>/dev/null
for b in "$BR" main; do
  git show-ref -q "refs/remotes/origin/$b" || continue
  L="$b"; git show-ref -q "refs/heads/$b" || L="origin/$b"
  BEHIND=$(git rev-list --count "$L..origin/$b" 2>/dev/null || echo 0)
  AHEAD=$(git rev-list --count "origin/$b..$L" 2>/dev/null || echo 0)
  if [ "${BEHIND:-0}" != "0" ]; then
    bad "동기화 $b" "origin/${b}보다 ${BEHIND}커밋 뒤짐"; hint "git pull --ff-only origin ${b}  (체크아웃 안 했으면 git fetch origin ${b}:${b})"
  elif [ "${AHEAD:-0}" != "0" ]; then
    warn "동기화 $b" "push 안 된 커밋 ${AHEAD}개"
  else
    ok "동기화 $b" "origin/${b}와 일치"
  fi
done

DIRTY=$(git status --porcelain | wc -l | tr -d ' ')
[ "$DIRTY" = "0" ] && ok "작업 트리" "clean" || warn "작업 트리" "변경 ${DIRTY}건"

# .gitignore 대상인데 이미 추적 중인 파일 (--no-index 없으면 추적 파일을 건너뛰어 한 건도 못 잡는다)
LEAKED=$(git ls-files -c | git check-ignore --no-index --stdin 2>/dev/null || true)
if [ -n "$LEAKED" ]; then
  bad "추적 배제" "gitignore 대상인데 추적 중인 파일이 있음"
  for f in $LEAKED; do hint "git rm --cached $f"; done
else
  ok "추적 배제" "gitignore 대상 중 추적 중인 파일 없음"
fi

# 장비 의존 잔재가 커밋되지 않았는지 (.DS_Store 등)
JUNK=$(git ls-files | grep -c '\.DS_Store$' || true)
[ "$JUNK" = "0" ] && ok "장비 잔재" ".DS_Store 등 추적 0건" || bad "장비 잔재" ".DS_Store ${JUNK}건이 추적 중"

# 절대경로 하드코딩 (CHANGE_DEVICE §2) — 경로가 바뀌면 조용히 깨지는 유일한 종류
ABS=$(grep -rl "/Users/" --include="*.html" --include="*.js" --include="*.css" --include="*.sh" . 2>/dev/null | grep -v '^./scripts/check-device.sh$' | wc -l | tr -d ' ')
[ "$ABS" = "0" ] && ok "절대경로" "하드코딩 0건" || { bad "절대경로" "${ABS}개 파일에 /Users/ 경로가 박혀 있음"; grep -rl "/Users/" --include="*.html" --include="*.js" --include="*.css" --include="*.sh" . | grep -v check-device | sed 's/^/          → /'; }

# Firebase 쓰기 권한 계정 — config 와 규칙 파일이 어긋나면 낙서장 글쓰기가 조용히 실패한다.
# 계정이 여러 개라 값이 아니라 **목록**을 대조한다(순서 무관 — 정렬해 비교).
CFG_MAILS=$(sed -n "/ADMIN_EMAILS = \[/,/\]/p" assets/js/firebase-config.js | grep -o "'[^']*@[^']*'" | tr -d "'" | sort | tr '\n' ' ' | sed 's/ $//')
RUL_MAILS=$(sed -n '/allow write:/,/;/p' firestore.rules | grep -o '"[^"]*@[^"]*"' | tr -d '"' | sort | tr '\n' ' ' | sed 's/ $//')
FIX_MAILS=$(printf '%s\n' $FIXED_ADMIN_MAILS | sort | tr '\n' ' ' | sed 's/ $//')
if [ -z "$CFG_MAILS" ] || [ -z "$RUL_MAILS" ]; then
  warn "쓰기 계정" "ADMIN_EMAILS 또는 firestore.rules 목록을 읽지 못함"
elif [ "$CFG_MAILS" != "$RUL_MAILS" ]; then
  bad "쓰기 계정" "config ≠ rules — 낙서장 글쓰기가 실패한다"
  hint "config: $CFG_MAILS"
  hint "rules : $RUL_MAILS"
elif [ "$CFG_MAILS" != "$FIX_MAILS" ]; then
  bad "쓰기 계정" "$CFG_MAILS — ADR D4로 고정된 목록이 아니다"
  hint "고정: $FIX_MAILS"
  hint "계정을 정말 바꾸려면 ADR D4와 ACCOUNT_COST §2를 먼저 갱신하고 이 스크립트의 FIXED_ADMIN_MAILS도 함께 고친다"
else
  ok "쓰기 계정" "$(printf '%s' "$CFG_MAILS" | wc -w | tr -d ' ')개 계정 — config·rules·ADR D4 일치"
fi

# 콘솔 쪽 실제 상태와 대조한다 — 저장소만 맞고 콘솔이 어긋난 상태를 잡기 위한 검사다.
#   ① 게시된 Firestore 규칙 == firestore.rules   (규칙은 수동 게시라 옛것이 남을 수 있다)
#   ② ADMIN_EMAILS 의 계정이 Authentication 에 실제로 등록돼 있나
# 둘 다 2026-08-29에 실제로 겪은 함정이다 — 코드·규칙은 맞는데 콘솔이 따라오지 않아
# 낙서장 글쓰기가 조용히 실패했다. 조회에는 그 프로젝트를 읽을 수 있는 gcloud 자격 증명이
# 필요하므로, 없는 장비에서는 조용히 건너뛴다(실패로 세지 않는다).
check_firebase_console() {
  command -v gcloud >/dev/null 2>&1 || return 0
  local proj tok acct rs live users missing extra m
  proj=$(sed -n "s/.*projectId: '\([^']*\)'.*/\1/p" assets/js/firebase-config.js)
  [ -n "$proj" ] || return 0

  for acct in $(gcloud auth list --format="value(account)" 2>/dev/null); do
    tok=$(gcloud auth print-access-token --account="$acct" 2>/dev/null) || continue
    [ -n "$tok" ] || continue
    rs=$(curl -sS -m 8 -H "Authorization: Bearer $tok" -H "x-goog-user-project: $proj" \
         "https://firebaserules.googleapis.com/v1/projects/$proj/releases/cloud.firestore" 2>/dev/null |
         python3 -c "import sys,json;print(json.load(sys.stdin).get('rulesetName',''))" 2>/dev/null)
    [ -n "$rs" ] || continue

    # ① 게시된 규칙
    live=$(curl -sS -m 8 -H "Authorization: Bearer $tok" -H "x-goog-user-project: $proj" \
           "https://firebaserules.googleapis.com/v1/$rs" 2>/dev/null |
           python3 -c "import sys,json;sys.stdout.write(json.load(sys.stdin)['source']['files'][0]['content'])" 2>/dev/null)
    if [ -z "$live" ]; then
      warn "게시된 규칙" "릴리스는 찾았으나 본문을 읽지 못함"
    elif [ "$live" = "$(cat firestore.rules)" ]; then
      ok "게시된 규칙" "콘솔 게시본이 firestore.rules 와 일치"
    else
      bad "게시된 규칙" "콘솔 게시본이 firestore.rules 와 다르다 — 낙서장 글쓰기가 조용히 실패할 수 있다"
      hint "콘솔 > Firestore Database > 규칙에 firestore.rules 를 붙여넣고 게시하세요"
    fi

    # ② Authentication 사용자
    users=$(curl -sS -m 8 -X POST -H "Authorization: Bearer $tok" -H "x-goog-user-project: $proj" \
            -H "Content-Type: application/json" -d '{}' \
            "https://identitytoolkit.googleapis.com/v1/projects/$proj/accounts:query" 2>/dev/null |
            python3 -c "import sys,json;print(' '.join(sorted(u.get('email','') for u in (json.load(sys.stdin).get('userInfo') or []) if u.get('email'))))" 2>/dev/null)
    if [ -z "$users" ]; then
      warn "Auth 사용자" "조회하지 못함 — 콘솔에서 확인하세요"
    else
      missing=""; extra=""
      for m in $CFG_MAILS; do
        case " $users " in *" $m "*) ;; *) missing="$missing $m";; esac
      done
      for m in $users; do
        case " $CFG_MAILS " in *" $m "*) ;; *) extra="$extra $m";; esac
      done
      if [ -n "$missing" ]; then
        bad "Auth 사용자" "ADMIN_EMAILS 에 있으나 Authentication 에 없음 —$missing"
        hint "그 계정으로는 로그인 자체가 실패한다. 콘솔 > Authentication > Users 에서 추가하세요"
      elif [ -n "$extra" ]; then
        warn "Auth 사용자" "ADMIN_EMAILS 에 없는 사용자가 남아 있음 —$extra (쓰기 권한은 없지만 정리 대상)"
      else
        ok "Auth 사용자" "$(printf '%s' "$users" | wc -w | tr -d ' ')명 — ADMIN_EMAILS 와 일치"
      fi
    fi
    return 0
  done
  return 0   # 조회 가능한 계정이 없는 장비 — 건너뛴다
}
check_firebase_console

# 형제 저장소 (CHANGE_DEVICE §5) — 문서가 ../business 로 지칭한다
[ -d ../business ] && ok "형제 저장소" "../business 있음" \
  || warn "형제 저장소" "../business 없음 — 문서의 ../business 상대 참조가 깨진 상태"

echo "── 사이트 무결성 ───────────────────────────"
ok "페이지 수" "${NPAGES}장 (index.html + src/*.html)"

# 공통 마크업 정본과 생성물의 드리프트 (ADR D3) — 마커 안을 직접 고치면 여기서 잡힌다
if [ -x ./scripts/build-partials.py ]; then
  if PARTIAL_OUT=$(./scripts/build-partials.py --check 2>&1); then
    ok "공통 마크업" "${PARTIAL_OUT#정본과 일치 — }"
  else
    bad "공통 마크업" "정본과 어긋난 페이지 있음 — ./scripts/build-partials.py 실행 필요"
  fi
fi
for entry in "${COMMON[@]}"; do
  label=${entry%%|*}; needle=${entry#*|}
  n=$(grep -l -F "$needle" "${PAGES[@]}" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" = "$NPAGES" ] && ok "$label" "${n}/${NPAGES}" || bad "$label" "${n}/${NPAGES} — 누락 페이지 있음"
done
STALE=$(grep -l 'md:hidden\|hidden md:flex\|hidden md:inline-flex' "${PAGES[@]}" 2>/dev/null | wc -l | tr -d ' ')
[ "$STALE" = "0" ] && ok "GNB md: 잔존" "0건 (lg: 상향 완료)" || bad "GNB md: 잔존" "${STALE}개 파일 — 폴드형 기기에서 nav 줄바꿈 재발"
INLINE=$(grep -l 'tailwind.config *=' "${PAGES[@]}" 2>/dev/null | wc -l | tr -d ' ')
[ "$INLINE" = "0" ] && ok "인라인 config" "0건 (공통 파일로 분리됨)" || bad "인라인 config" "${INLINE}개 파일에 남아 있음"

python3 - <<'PY'
import re, os, glob
pages = ['index.html'] + sorted(glob.glob('src/*.html'))
total = 0; broken = []
for p in pages:
    base = os.path.dirname(p)
    for m in re.finditer(r'(?:href|src)="([^"#][^"]*)"', open(p, encoding='utf-8').read()):
        u = m.group(1)
        if u.startswith(('http://', 'https://', '//', 'mailto:', 'data:', '#', 'javascript:')):
            continue
        total += 1
        t = u.split('?')[0].split('#')[0]
        path = t[1:] if t.startswith('/') else os.path.normpath(os.path.join(base, t))
        if not os.path.exists(path):
            broken.append(f"{p} -> {u}")
if broken:
    print(f"❌  {'내부 링크':<14} {total}건 중 {len(broken)}건 깨짐")
    for b in broken[:10]:
        print("          → " + b)
else:
    print(f"✅  {'내부 링크':<14} {total}건 검사 / 깨짐 0건")

h = open('index.html', encoding='utf-8').read()
parts = []
for sid in ['lang', 'algo', 'web', 'game', 'agent-ai']:
    i = h.find(f'id="{sid}"'); j = h.find('</section>', i)
    seg = h[i:j]
    a = len(re.findall(r'<a[^>]*course-card', seg)); d = len(re.findall(r'<div[^>]*course-card', seg))
    parts.append(f"{sid} {a}/{a+d}")
print(f"✅  {'카드 연결':<14} " + " · ".join(parts) + "  (연결/전체)")
PY
[ $? -eq 0 ] || true
grep -q '내부 링크.*깨짐 0건' /dev/null 2>&1  # (출력은 위 python 이 직접 담당)

echo "── 문서 정합성 (§7) ────────────────────────"
python3 - <<'PY'
import re, os, glob, sys
fail = 0

def ok(l, m):  print(f"✅  {l:<14} {m}")
def bad(l, m):
    global fail; fail += 1; print(f"❌  {l:<14} {m}")

# 1층 문서(현재 사실)만 검사한다. DEVLOG 는 3층(시간 기록)이라 삭제·개명된 옛 파일명이 정상적으로 남는다.
docs = ['CLAUDE.md'] + [d for d in sorted(glob.glob('docs/*.md')) if os.path.basename(d) != 'DEVLOG.md']

# 1) 문서가 백틱/링크로 가리키는 저장소 경로가 실재하는가
missing = set()
for d in docs:
    s = open(d, encoding='utf-8').read()
    for ref in re.findall(r'`((?:docs|tasks|report|scripts|assets|src)/[A-Za-z0-9_./*-]+)`', s):
        if any(x in ref for x in ('<', 'YYYY', '*', '...', '…')):
            continue
        if not os.path.exists(ref):
            missing.add(f"{d}: {ref}")
    for ref in re.findall(r'\]\((?!https?:|#|mailto:)([^)#]+)\)', s):
        ref = ref.strip()
        if any(x in ref for x in ('<', 'YYYY', '*')):
            continue
        p = os.path.normpath(os.path.join(os.path.dirname(d), ref))
        if not os.path.exists(p):
            missing.add(f"{d}: {ref}")
missing = {m for m in missing if 'mockup.html' not in m}   # 2026-08-22 삭제된 파일의 이력 서술
ok('문서 참조', '가리키는 저장소 경로 전부 실재') if not missing else \
    bad('문서 참조', '없는 경로: ' + ', '.join(sorted(missing)[:5]))

# 2) ARCHITECTURE §1 표에 적힌 CDN 버전 vs 실제 참조 버전
arch = open('docs/ARCHITECTURE.md', encoding='utf-8').read()
html = ''.join(open(p, encoding='utf-8').read() for p in ['index.html'] + sorted(glob.glob('src/*.html')))
js = ''.join(open(p, encoding='utf-8').read() for p in glob.glob('assets/js/*.js'))
actual = {
    'Pretendard': (re.search(r'pretendard@v([0-9.]+)', html) or [None, '?'])[1],
    'Swiper':     (re.search(r'swiper@([0-9]+)', html) or [None, '?'])[1],
    'AOS':        (re.search(r'aos@([0-9.]+)', html) or [None, '?'])[1],
    'Firebase':   (re.search(r'firebasejs/([0-9.]+)', js) or [None, '?'])[1],
}
drift = [f"{k} 실제 {v}" for k, v in actual.items() if v not in arch]
ok('라이브러리 버전', ' · '.join(f"{k} {v}" for k, v in actual.items()) + ' — §1 표와 일치') if not drift else \
    bad('라이브러리 버전', '§1 표와 다름: ' + ', '.join(drift))

# 3) GNB "준비중" 링크 vs ARCHITECTURE §6 서브도메인 표
idx = open('index.html', encoding='utf-8').read()
head = idx[:idx.find('</header>')]
pending = sorted(set(re.findall(r'>\s*([A-Za-z가-힣 ]{2,20}?)\s*<span[^>]*>준비중', head)))
ok('GNB 준비중', (', '.join(pending) or '없음') + ' — §6 표와 대조할 것') if len(pending) <= 1 else \
    bad('GNB 준비중', f'{len(pending)}건: ' + ', '.join(pending))

# 4) 문서 내부 §n 상호참조 유효성
#    `X.md` §n 처럼 문서명이 바로 앞에 붙은 것만 그 문서의 절로 보고, 그 외는 자기 문서의 절로 본다.
# report/*.md 도 후보에 넣는다 — 문서가 보고서의 절(`report/....md` §5)을 가리키는 경우가 있다.
secs = {os.path.basename(d): {int(m) for m in re.findall(r'^## (\d+)\.', open(d, encoding='utf-8').read(), re.M)}
        for d in ['CLAUDE.md'] + sorted(glob.glob('docs/*.md')) + sorted(glob.glob('report/*.md'))}
badrefs = []
for d in docs:
    s_ = open(d, encoding='utf-8').read()
    for m in re.finditer(r'`(?:[A-Za-z0-9_./-]*/)?([A-Za-z0-9_.-]+\.md)`[^§`\n]{0,12}§(\d+)', s_):
        tgt, n = m.group(1), int(m.group(2))
        if secs.get(tgt) and n not in secs[tgt]:
            badrefs.append(f"{d}: {tgt} §{n}")
    own = os.path.basename(d)
    for m in re.finditer(r'§(\d+)', s_):
        pre = s_[max(0, m.start() - 40):m.start()]
        if re.search(r'`(?:[A-Za-z0-9_./-]*/)?[A-Za-z0-9_.-]+\.md`[^§`\n]{0,12}$', pre):
            continue                      # 위에서 이미 검사한 타 문서 참조
        n = int(m.group(1))
        line = s_[s_.rfind('\n', 0, m.start()) + 1:m.start()]
        named = re.findall(r'`(?:[A-Za-z0-9_./-]*/)?([A-Za-z0-9_.-]+\.md)`', line)   # 같은 줄에서 앞서 언급된 문서(§3·§5 처럼 이어지는 참조)
        cand = [own] + named
        if not any(n in secs.get(c, set()) for c in cand):
            badrefs.append(f"{d}: §{n}")
ok('§n 상호참조', '깨진 참조 0건') if not badrefs else bad('§n 상호참조', ', '.join(sorted(set(badrefs))[:5]))

sys.exit(1 if fail else 0)
PY
[ $? -eq 0 ] || FAIL=$((FAIL+1))

# DEVLOG 최신 커밋 버전 기록 여부
LASTV=$(git log -1 --format=%s | grep -o '^v[0-9.]*' || true)
if [ -z "$LASTV" ]; then
  warn "DEVLOG" "최신 커밋이 vX.XX 형식이 아님"
elif grep -q "$LASTV" docs/DEVLOG.md; then
  ok "DEVLOG" "최신 커밋 $LASTV 기록됨"
else
  warn "DEVLOG" "최신 커밋 ${LASTV}가 DEVLOG에 없음"
fi

echo "── Claude 경로 키 잔재 (§3) ────────────────"
# 저장소가 아니라 이 장비의 ~/ 상태를 본다. 읽기만 하고 고치지 않는다
# (Claude Code 실행 중 편집은 종료 시 덮어써진다 — CHANGE_DEVICE §6-1).
python3 - <<'PY'
import json, os, glob
home = os.path.expanduser('~')
cfg = f"{home}/.claude.json"; hist = f"{home}/.claude/history.jsonl"
stale = []
try:
    d = json.load(open(cfg, encoding='utf-8'))
    stale += [k for k in d.get('projects', {}) if not os.path.isdir(k)]
    for repo, paths in (d.get('githubRepoPaths') or {}).items():
        if isinstance(paths, list):
            stale += [p for p in paths if not os.path.isdir(p)]
except Exception as e:
    print(f"⚠️   {'.claude.json':<14} 읽기 실패: {e}")
n_hist = 0
try:
    seen = set()
    for line in open(hist, encoding='utf-8'):
        line = line.strip()
        if not line:
            continue
        p = json.loads(line).get('project', '')
        if p and not os.path.isdir(p):
            n_hist += 1; seen.add(p)
except Exception:
    pass
live = {os.path.basename(p)[:-6] for p in glob.glob(f"{home}/.claude/projects/*/*.jsonl")}
orph = sum(len([n for n in os.listdir(f"{home}/.claude/{b}") if n not in live])
           for b in ('file-history', 'session-env') if os.path.isdir(f"{home}/.claude/{b}"))
if stale or n_hist or orph:
    print(f"⚠️   {'경로 키 잔재':<14} .claude.json {len(set(stale))}건 · history {n_hist}줄 · 고아 아티팩트 {orph}개")
    print("          → Claude Code 종료 후 ~/migrate-claude-path.sh 실행 (docs/CHANGE_DEVICE.md §4)")
else:
    print(f"✅  {'경로 키 잔재':<14} 없음")
PY

echo "── 문서 드리프트 감사 ──────────────────────"
# 장비를 옮겼을 뿐인데 1층 문서(현재 사실)가 바뀌고 있다면 십중팔구 "관측값"이 들어간 것이다.
# 관측값은 다음 장비에서 또 어긋나 커밋을 낳는다(핑퐁). DEVLOG/report는 3층(시간 기록)이라 제외.
L1="CLAUDE.md docs/PRD.md docs/DEV_PLAN.md docs/ARCHITECTURE.md docs/CHANGE_DEVICE.md docs/ACCOUNT_COST.md"
L1EXIST=""
for f in $L1; do [ -f "$f" ] && L1EXIST="$L1EXIST $f"; done
ADDED=$(git diff HEAD -- $L1EXIST 2>/dev/null | grep '^+' | grep -v '^+++' || true)
if [ -z "$ADDED" ]; then
  ok "문서 드리프트" "1층 문서에 변경 없음 — 장비 이동만으로 생기는 커밋 없음"
else
  SUSPECT=$(printf '%s\n' "$ADDED" \
    | grep -v '^+| 20[0-9][0-9]-' \
    | grep -v 'check-device\.sh\|--audit' \
    | grep -E '실측|이 장비에서|재조회|현재 [0-9]|[0-9]+건|[0-9]+/30|[0-9]+\.[0-9]+\.[0-9]+|[0-9]+(\.[0-9]+)? ?(KB|MB|GB)' \
    || true)
  CHANGED=$(git diff --name-only HEAD -- $L1EXIST 2>/dev/null | tr '\n' ' ')
  if [ -n "$SUSPECT" ]; then
    warn "문서 드리프트" "1층 문서에 관측값으로 보이는 줄이 있음 ($CHANGED)"
    printf '%s\n' "$SUSPECT" | head -12 | sed 's/^/          │ /'
    hint "'조회하면 알 수 있는 값'이면 문서에서 빼고 이 스크립트로 대체하거나 report/에 둔다"
    hint "'결정한 것'이면 그대로 커밋해도 된다 (판정 기준: CLAUDE.md 제1원칙)"
  else
    ok "문서 드리프트" "1층 문서 변경 ${CHANGED}— 관측값 패턴 없음"
  fi
fi

if [ "$AUDIT_ONLY" = "1" ]; then
  echo "────────────────────────────────────────────"
  [ "$FAIL" = "0" ] && echo "감사 완료 (경고 ${WARN}건)" || echo "감사 완료 (실패 ${FAIL}건, 경고 ${WARN}건)"
  exit 0
fi

if [ "$QUICK" = "0" ]; then
  echo "── 로컬 서버 ───────────────────────────────"
  if lsof -i "tcp:${PORT}" >/dev/null 2>&1; then
    warn "로컬 서버" "포트 ${PORT} 사용 중 — 검사 생략 (CHECK_DEVICE_PORT=다른포트)"
  else
    python3 -m http.server "$PORT" >/dev/null 2>&1 &
    SRV=$!
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      curl -s -o /dev/null "http://localhost:${PORT}/index.html" && break
      sleep 0.3
    done
    BADP=""
    for u in /index.html /assets/css/base.css /assets/js/tailwind-config.js /assets/image/og-image.png /src/about.html /src/lang-cp.html /src/algo-bst.html; do
      code=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${PORT}${u}")
      [ "$code" = "200" ] || BADP="$BADP $u($code)"
    done
    kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null
    [ -z "$BADP" ] && ok "로컬 서버" "7개 경로 전부 200" || bad "로컬 서버" "비정상 응답:$BADP"
  fi
fi

echo "────────────────────────────────────────────"
if [ "$FAIL" = "0" ] && [ "$WARN" = "0" ]; then
  echo "전부 통과 — 장비 이동으로 고칠 것 없음 (커밋 불필요)"
else
  echo "실패 ${FAIL}건, 경고 ${WARN}건"
fi
[ "$FAIL" = "0" ]
