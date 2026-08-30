#!/usr/bin/env python3
"""공통 마크업 정본(partials/)을 각 페이지의 마커 사이에 주입한다 — ARCHITECTURE.md ADR D3.

    ./scripts/build-partials.py           주입하고 바뀐 파일을 보고
    ./scripts/build-partials.py --check   바뀔 것이 있으면 종료코드 1 (드리프트 검사, 파일 수정 없음)

페이지에는 아래 마커만 넣어 두면 된다. 마커 사이는 생성물이므로 직접 고치지 않는다 —
고쳐야 할 것은 언제나 partials/ 쪽이다.

    <!-- @partial:footer -->
    ...생성물...
    <!-- /@partial:footer -->

페이지별로 달라지는 것은 경로 접두사뿐이라, 파일 위치에서 계산해 토큰을 치환한다.

    토큰        루트(index.html)   src/ 페이지
    {{HOME}}    ""                 "../index.html"   → href="{{HOME}}#lang"
    {{SRC}}     "src/"             ""                → href="{{SRC}}about.html"
    {{ASSET}}   "assets/"          "../assets/"      → src="{{ASSET}}image/logo.png"

정본을 여는 주석(<!-- ... -->)은 주입 대상에서 제외된다 — 정본 파일에만 남는 설명이다.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PARTIALS = ROOT / "partials"

# 주입 대상 페이지 — 루트 진입점 + src/ 전체
PAGES = [ROOT / "index.html"] + sorted((ROOT / "src").glob("*.html"))

# 정본 맨 앞의 설명 주석은 페이지로 옮기지 않는다
LEADING_COMMENT = re.compile(r"\A\s*<!--.*?-->\s*\n", re.S)


def tokens_for(page: Path) -> dict[str, str]:
    """페이지 위치에서 경로 접두사를 계산한다."""
    at_root = page.parent == ROOT
    return {
        # 루트에서는 자기 자신이라 앵커만, src/ 에서는 한 단계 올라가야 한다(`index.html`로 쓰면 src/index.html 을 가리킨다).
        "HOME": "" if at_root else "../index.html",
        "SRC": "src/" if at_root else "",
        "ASSET": "assets/" if at_root else "../assets/",
    }


def render(name: str, page: Path) -> str:
    body = (PARTIALS / f"{name}.html").read_text(encoding="utf-8")
    body = LEADING_COMMENT.sub("", body).rstrip("\n")
    for key, value in tokens_for(page).items():
        body = body.replace("{{%s}}" % key, value)
    left = re.search(r"\{\{(\w+)\}\}", body)
    if left:
        raise SystemExit(f"오류: {name}.html 에 치환되지 않은 토큰 {{{{{left.group(1)}}}}} 이(가) 남았습니다.")
    return body


def apply_to(page: Path) -> str | None:
    """마커를 정본으로 채운 새 본문을 돌려준다. 바뀔 게 없으면 None."""
    text = original = page.read_text(encoding="utf-8")
    for partial in sorted(PARTIALS.glob("*.html")):
        name = partial.stem
        # 여는 마커의 들여쓰기까지 통째로 잡아 블록 전체를 다시 쓴다(비어 있어도 물린다).
        pattern = re.compile(
            r"^([ \t]*)<!-- @partial:{0} -->.*?^[ \t]*<!-- /@partial:{0} -->".format(name),
            re.S | re.M,
        )
        if not pattern.search(text):
            continue
        body = render(name, page)
        text = pattern.sub(
            lambda m: "{0}<!-- @partial:{1} -->\n{2}\n{0}<!-- /@partial:{1} -->".format(
                m.group(1), name, body
            ),
            text,
        )
    return None if text == original else text


def main() -> int:
    check = "--check" in sys.argv[1:]
    if not PARTIALS.is_dir():
        print(f"오류: {PARTIALS} 가 없습니다.", file=sys.stderr)
        return 2

    stale: list[Path] = []
    used = 0
    for page in PAGES:
        if "@partial:" not in page.read_text(encoding="utf-8"):
            continue
        used += 1
        new = apply_to(page)
        if new is None:
            continue
        stale.append(page)
        if not check:
            page.write_text(new, encoding="utf-8")

    names = ", ".join(sorted(p.stem for p in PARTIALS.glob("*.html")))
    if check:
        if stale:
            print(f"드리프트 {len(stale)}건 — 정본과 어긋난 페이지:", file=sys.stderr)
            for page in stale:
                print(f"  {page.relative_to(ROOT)}", file=sys.stderr)
            print("  → ./scripts/build-partials.py 를 실행해 맞추세요.", file=sys.stderr)
            return 1
        print(f"정본과 일치 — 페이지 {used}장 / 정본 [{names}]")
        return 0

    if stale:
        print(f"갱신 {len(stale)}장 / 마커 보유 {used}장 · 정본 [{names}]")
        for page in stale:
            print(f"  {page.relative_to(ROOT)}")
    else:
        print(f"변경 없음 — 페이지 {used}장 이미 정본과 일치 · 정본 [{names}]")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
