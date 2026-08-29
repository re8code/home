# CHANGE_DEVICE.md — 장비 이동 프로토콜

장비를 옮기거나 같은 장비 안에서 저장소 경로를 바꿀 때 따르는 절차. `CLAUDE.md` 제1원칙에 따라 **장비 이동이 발생하면 다른 작업보다 이 프로토콜을 우선 진행**하고, 정리가 끝나면 **반드시 전체 문서 정합성 확인까지 이어서** 수행한다.

- 최종 갱신: 2026-08-29 (2026-08-26 `~/dev/recode-ai/` → `~/recode-ai/` 이동을 실제로 수행하며 정리 — 상세: `../report/2026-08-29-repo-path-move-cleanup.md`)

---

## 0. 핵심 — 깨지는 것은 저장소가 아니다

저장소는 이미 경로 독립적이다(상대경로 · `/assets/...` 루트 절대참조 · `start.sh`의 `BASH_SOURCE`). 실제로 깨지는 것은 **도구가 절대경로를 키로 들고 있는 상태**다 — Claude Code의 세션 이력, 메모리, 신뢰 설정, 입력 이력.

경로만 확인하고 옮기면 저장소는 멀쩡한데 세션 이력과 신뢰 설정을 잃는다. 반대로 상태만 옮기고 형제 저장소를 확인하지 않으면 `../business` 같은 상대 참조가 조용히 깨진다.

---

## 1. 이동 전 (구 장비 / 옛 경로에서)

- [ ] **커밋·푸시 완료** — `git status` 클린, 로컬에만 있는 커밋 없음(`git log origin/dev..dev`).
- [ ] **진행 중이던 내용이 저장소 문서에 있는지 확인** — `CLAUDE.md` "여러 장비 간 작업 연속성" 규칙대로, Claude 개인 메모리에만 있고 저장소에 없는 정보는 이동 순간 사라진 것과 같다. `DEVLOG.md`/`report/`에 먼저 남긴다.
- [ ] **형제 저장소를 함께 옮길지 결정** — 아래 §5 참고.

## 2. 이동 후 — 저장소 무결성 확인

- [ ] `git remote -v` · `git status` · `git branch -vv` 정상.
- [ ] **절대경로 하드코딩 0건**: `grep -rn "/Users/" --include="*.html" --include="*.js" --include="*.css" --include="*.sh" .`
- [ ] **모든 브랜치 pull** — 다른 장비에서 올린 커밋이 있을 수 있다. 작업 브랜치는 `git pull --ff-only`, 체크아웃하지 않은 브랜치는 `git fetch origin main:main`.
- [ ] **로컬 서버 응답** — `./start.sh` 또는 `python3 -m http.server`로 띄우고 `/index.html` · `/assets/css/base.css` · `/assets/js/tailwind-config.js` · `/src/about.html` · 이미지 하나가 200인지 확인.

## 3. 이동 후 — 경로를 키로 보관된 상태 정리

| 위치 | 무엇이 들어 있나 | 잃으면 |
| --- | --- | --- |
| `~/.claude/projects/<경로키>/` | 세션 트랜스크립트(`*.jsonl`), `memory/` | `--continue`/`--resume` 불가, 프로젝트 메모리 소실 |
| `~/.claude.json` → `projects["<절대경로>"]` | `hasTrustDialogAccepted`, `allowedTools` | 새 경로에서 신뢰 대화상자가 다시 뜸 |
| `~/.claude.json` → `githubRepoPaths` | 저장소 ↔ 경로 매핑 | 저장소 인식이 어긋남 |
| `~/.claude/history.jsonl` | 프롬프트 입력 이력(`project` 필드가 경로) | ↑ 키로 과거 입력을 못 불러옴 |
| `~/.claude/file-history/<세션ID>/` | 그 세션이 편집한 파일 스냅샷 | (세션을 지워도 **함께 지워지지 않는다** — 고아로 남음) |
| `~/.claude/session-env/<세션ID>/` | 세션 환경 | 〃 |

**경로키 규칙**: 절대경로의 `/`를 `-`로 바꾼 이름. `/Users/won/recode-ai/home` → `-Users-won-recode-ai-home`.

선택은 둘 중 하나다.

- **이관** — 옛 경로 항목을 새 경로로 옮겨 이력·신뢰 설정을 승계한다(권장).
- **폐기** — 옛 항목을 지우고 새 경로에서 빈 세션으로 시작한다. 이때도 §4의 고아 아티팩트는 **따로** 지워야 한다.

## 4. 자동화 스크립트

아래를 **저장소 밖**(`~/migrate-claude-path.sh`)에 쓰고 실행한다. 저장소 안에 두면 이동 대상에 같이 끌려가고 `git status`도 더럽힌다.

```bash
#!/usr/bin/env bash
# Claude Code 가 경로를 키로 들고 있는 상태를 옛 경로 → 새 경로로 이관한다. 멱등.
set -euo pipefail

# ── 이동한 저장소를 여기에 나열한다 (옛 경로|새 경로) ──
PAIRS=(
  "/Users/won/dev/recode-ai/home|/Users/won/recode-ai/home"
  "/Users/won/dev/recode-ai/business|/Users/won/recode-ai/business"
)
# 이 장비에서 완전히 사라진 저장소 (기록째 삭제)
GONE=()

# ★ 가장 중요한 안전장치 — 실행 중이면 중단
if pgrep -x claude >/dev/null 2>&1 || pgrep -f "bin/claude" >/dev/null 2>&1; then
  echo "중단: Claude Code 를 모두 종료한 뒤 다시 실행하세요." >&2; exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
for f in "$HOME/.claude.json" "$HOME/.claude/history.jsonl"; do
  cp -p "$f" "$f.bak.$STAMP"
done
echo "백업: *.bak.$STAMP"

PAIRS="${PAIRS[*]}" GONE="${GONE[*]:-}" python3 - <<'PY'
import json, os, sys, tempfile
PAIRS = [tuple(p.split("|")) for p in os.environ["PAIRS"].split()]
GONE  = [g for g in os.environ.get("GONE", "").split() if g]
home  = os.path.expanduser("~")
cfg, hist = f"{home}/.claude.json", f"{home}/.claude/history.jsonl"
changed = []

# 1) 프로젝트 디렉터리(세션 이력 + memory/) 이관
for old, new in PAIRS:
    key = lambda p: p.replace("/", "-")
    o, n = f"{home}/.claude/projects/{key(old)}", f"{home}/.claude/projects/{key(new)}"
    if os.path.isdir(o) and not os.path.exists(n):
        os.rename(o, n); changed.append(f"projects 디렉터리 이관: {os.path.basename(o)} -> {os.path.basename(n)}")

# 2) ~/.claude.json — projects · githubRepoPaths
data = json.load(open(cfg, encoding="utf-8"))
projects = data.get("projects", {})
for old, new in PAIRS:
    if old in projects:
        if new not in projects:
            projects[new] = projects[old]; changed.append(f"projects: {old} -> {new} 승계")
        else:
            changed.append(f"projects: {old} 제거(새 경로에 설정 있음)")
        del projects[old]
for g in GONE:
    if g in projects: del projects[g]; changed.append(f"projects: {g} 제거(저장소 없음)")

for repo in list(data.get("githubRepoPaths", {})):
    paths = data["githubRepoPaths"][repo]
    if not isinstance(paths, list): continue
    before = list(paths)
    for old, new in PAIRS:
        if old in paths:
            paths[:] = [p for p in paths if p != old]
            if new not in paths: paths.insert(0, new)
    paths[:] = [p for p in paths if p not in GONE]
    if paths != before: changed.append(f"githubRepoPaths[{repo}] 정리")
    if not paths: del data["githubRepoPaths"][repo]

if any("projects" in c or "githubRepoPaths" in c for c in changed):
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(cfg), prefix=".claude.json.")
    with os.fdopen(fd, "w", encoding="utf-8") as f: json.dump(data, f, ensure_ascii=False, indent=2)
    json.load(open(tmp, encoding="utf-8"))          # 파싱 검증 후 원자적 교체
    os.replace(tmp, cfg)

# 3) history.jsonl — project 필드만. display 는 사용자가 친 원문이므로 불변.
text = original = open(hist, encoding="utf-8").read()
for old, new in PAIRS:
    needle = f'"project":"{old}"'                    # 원문은 콜론 뒤 공백 없음
    if (n := text.count(needle)):
        text = text.replace(needle, f'"project":"{new}"'); changed.append(f"history: {old} {n}건 이관")
if GONE:
    kept = [l for l in text.splitlines()
            if l.strip() and json.loads(l).get("project", "") not in GONE]
    if len(kept) != len(text.splitlines()):
        changed.append(f"history: 사라진 저장소 {len(text.splitlines())-len(kept)}줄 삭제")
        text = "\n".join(kept) + "\n"
if text != original:
    for l in text.splitlines():
        if l.strip(): json.loads(l)                  # 전 줄 파싱 검증
    with open(hist, "r+", encoding="utf-8") as f:    # ★ 같은 inode 유지 (append fd 보호)
        f.seek(0); f.write(text); f.truncate()

# 4) 고아 아티팩트 — 살아있는 세션에 속하지 않는 file-history / session-env
live = {os.path.basename(p)[:-6] for p in
        __import__("glob").glob(f"{home}/.claude/projects/*/*.jsonl")}
for base in ("file-history", "session-env"):
    d = f"{home}/.claude/{base}"
    for name in (os.listdir(d) if os.path.isdir(d) else []):
        if name not in live:
            __import__("shutil").rmtree(f"{d}/{name}", ignore_errors=True)
            changed.append(f"{base}/{name} 고아 삭제")

print("\n".join("변경: " + c for c in changed) if changed else "NOCHANGE")
sys.exit(0 if changed else 2)
PY
```

**실행 전 반드시 사본으로 검증한다** — 스크립트에 박힌 파이썬을 그대로 꺼내 `~/.claude.json`·`history.jsonl` **복사본**에 `HOME`을 가짜 디렉터리로 지정해 돌려보고, 최상위 키 개수·순서 보존, 새 경로 항목 값 동일, 옛 경로 잔존 0건, 재실행 시 `NOCHANGE`를 확인한 뒤 원본에 적용한다.

## 5. 형제 저장소

`home`과 `business`는 `~/recode-ai/` 아래 **형제**여야 한다. 두 저장소의 문서가 서로를 `../business` · `../home`으로 지칭하기 때문에, **한쪽만 옮기면 그 상대 참조가 조용히 깨진다**(파일이 없다는 것 외에 아무 경고도 없다).

- [ ] 이동 후 `ls ../business` 로 형제 관계 확인.
- [ ] 한쪽만 옮겨야 한다면, 그동안은 절대경로로 참조하고 문서에는 손대지 않는다(곧 맞춰질 상태를 문서에 반영하면 두 번 고치게 된다).

## 6. 함정 — 실제로 당한 것들

1. **Claude Code는 `~/.claude.json`을 메모리에 들고 있다가 종료 시 되쓴다.** 실행 중에 편집하면 그 변경이 조용히 사라진다. 스크립트가 `pgrep`으로 중단하는 이유이고, **세션 종료 후 한 번 더 돌려** 되살아난 항목이 없는지 확인해야 하는 이유다(멱등이라 안전).
2. **`history.jsonl`은 실행 중에도 append된다.** `os.replace`로 inode를 갈면 실행 중인 세션의 append가 사라진 inode로 들어간다. **제자리 재작성**(`r+` → `seek(0)` → `write` → `truncate`)으로 처리한다.
3. **`display` 필드는 건드리지 않는다.** 사용자가 타이핑한 프롬프트 본문 안에 옛 경로가 들어 있을 수 있는데, 그건 경로 키가 아니라 발화 기록이다. 바꾸면 과거 발화를 위조하게 된다. 치환 대상은 `"project":"..."` 뿐이다.
4. **`"project":"..."`에는 콜론 뒤 공백이 없다.** 샘플을 `json.dumps`로 다시 찍어보면 공백이 붙어 보여 `"project": "..."`로 착각하기 쉽다 — **원문을 직접 봐야 한다**.
5. **세션 트랜스크립트를 지워도 `file-history/<세션ID>/`는 함께 지워지지 않는다.** 실제로 19MB·561파일이 고아로 남아 있었다.
6. **저장소가 사라진 프로젝트 항목**은 이관이 아니라 삭제 대상이다. 다만 다른 장비에 있을 수 있으니 지우기 전에 확인한다.

## 7. 마무리 — 문서 정합성 확인 (필수)

`CLAUDE.md` 제1원칙에 따라 **장비 이동 정리가 끝나면 반드시 전체 문서 정합성 확인을 진행한다.** 절차와 점검 항목은 `../report/2026-08-29-docs-consistency-check.md`를 템플릿으로 삼는다 — 30개 페이지 공통 요소, GNB 브레이크포인트, 내부 링크 전수, 카드 연결, CDN 라이브러리 버전 vs `ARCHITECTURE.md` §1, GNB 링크 vs §6, `§n` 상호참조, `DEV_PLAN` Phase 상태, 로컬 서버 응답.

마지막으로 이동 사실을 `DEVLOG.md`에 남기고, 이번 이동에서 **이 프로토콜에 빠진 단계나 새로 발견한 함정이 있으면 이 문서에 추가**한다.
