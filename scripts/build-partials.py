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


SITE = "https://recode.ai.kr/"

TITLE_RE = re.compile(r"<title>(.*?)</title>", re.S)
DESC_RE = re.compile(r'<meta name="description" content="(.*?)"\s*/?>', re.S)


def attr(text: str) -> str:
    """<title> 원문을 속성값으로 옮긴다.

    원문은 이미 HTML 이스케이프된 상태이므로 **그대로 복사**한다 — 여기서 `&`를 다시
    이스케이프하면 나중에 제목에 `Web &amp; WebApp` 같은 표기가 들어왔을 때 `&amp;amp;`로
    이중 이스케이프된다. 속성을 깨뜨리는 따옴표만 바꾼다.
    """
    return text.replace('"', "&quot;")


def tokens_for(page: Path) -> dict[str, str]:
    """페이지 위치에서 경로 접두사를, 페이지 본문에서 제목·설명을 계산한다."""
    at_root = page.parent == ROOT
    text = page.read_text(encoding="utf-8")

    title = TITLE_RE.search(text)
    desc = DESC_RE.search(text)
    if not title or not desc:
        raise SystemExit(f"오류: {page} 에 <title> 또는 <meta name=\"description\"> 이 없습니다.")

    return {
        # 루트에서는 자기 자신이라 앵커만, src/ 에서는 한 단계 올라가야 한다(`index.html`로 쓰면 src/index.html 을 가리킨다).
        "HOME": "" if at_root else "../index.html",
        "HOME_HREF": "#" if at_root else "../index.html",
        "SRC": "src/" if at_root else "",
        "ASSET": "assets/" if at_root else "../assets/",
        # OG 태그용 — 페이지의 <title>/<meta description>/경로에서 파생시켜, 문구를 고칠 때
        # OG를 따로 챙겨야 하던 이중 관리를 없앤다(종전 관례는 CLAUDE.md "Open Graph" 항목 참고).
        "URL": SITE + ("" if at_root else f"src/{page.name}"),
        "TITLE": attr(title.group(1).strip()),
        "DESC": attr(desc.group(1).strip()),
    }


# 코스 바로가기 탭 — 정본에는 전부 평범한 링크로 두고, 자기 자신을 가리키는 것만 여기서 활성 처리한다.
# `filter-tab` 클래스를 가진 링크에만 적용한다 — GNB·푸터에도 자기 자신을 가리키는 링크가 있지만
# (about.html 의 "소개" 등) 그쪽은 현재 페이지 강조를 하지 않는 것이 관례이기 때문.
TAB_RE = re.compile(r'<a href="(?P<href>[^"]+)" class="filter-tab (?P<rest>[^"]*)"')


def mark_current(body: str, page: Path) -> str:
    def sub(m: re.Match[str]) -> str:
        if m.group("href") != page.name:
            return m.group(0)
        return '<a href="{0}" aria-current="page" class="filter-tab is-active {1}"'.format(
            m.group("href"), m.group("rest")
        )

    return TAB_RE.sub(sub, body)


def render(name: str, page: Path) -> str:
    body = (PARTIALS / f"{name}.html").read_text(encoding="utf-8")
    body = LEADING_COMMENT.sub("", body).rstrip("\n")
    for key, value in tokens_for(page).items():
        body = body.replace("{{%s}}" % key, value)
    body = mark_current(body, page)
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
