#!/usr/bin/env python3
"""Rebuild the RECENT and PINNED blocks in LEARNINGS.md from .learnings/L-*.md.

Usage: _kln_digest.py <digest-path> <learnings-dir>
"""
from __future__ import annotations

import re
import sys
from pathlib import Path


def parse_frontmatter(text: str) -> dict[str, str]:
    m = re.match(r"---\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            k, _, v = line.partition(":")
            out[k.strip()] = v.strip()
    return out


def first_rule(text: str) -> str:
    m = re.search(r"^##\s*Rule\s*\n+(.+?)(?:\n##|\Z)", text, re.MULTILINE | re.DOTALL)
    if not m:
        return "(no rule line)"
    for line in m.group(1).splitlines():
        line = line.strip()
        if line:
            return line
    return "(no rule line)"


def render_row(path: Path, meta: dict[str, str], rule: str, digest_dir: Path) -> str:
    rel = path.relative_to(digest_dir).as_posix()
    scope = meta.get("scope", "?")
    cost = meta.get("cost", "?")
    return f"- [{meta.get('id', path.stem)}]({rel}) — {rule} _(scope: {scope}, cost: {cost})_"


def main() -> None:
    digest_path = Path(sys.argv[1])
    learnings_dir = Path(sys.argv[2])
    root = digest_path.parent

    files = sorted(learnings_dir.glob("L-*.md"), key=lambda p: p.stat().st_mtime, reverse=True)

    rows: list[tuple[Path, dict[str, str], str]] = []
    for p in files:
        text = p.read_text()
        meta = parse_frontmatter(text)
        rule = first_rule(text)
        rows.append((p, meta, rule))

    recent = [render_row(p, m, r, root) for p, m, r in rows[:10]]

    pinned_rows = [
        (p, m, r) for p, m, r in rows
        if m.get("recurring") == "true" or m.get("cost") == "high"
    ][:15]
    pinned = [render_row(p, m, r, root) for p, m, r in pinned_rows]

    content = digest_path.read_text()

    def replace(body: str, begin: str, end: str, new_inner: list[str]) -> str:
        pattern = re.compile(
            re.escape(begin) + r".*?" + re.escape(end),
            re.DOTALL,
        )
        inner = "\n".join(new_inner) if new_inner else "_(none yet)_"
        replacement = f"{begin}\n{inner}\n{end}"
        return pattern.sub(replacement, body, count=1)

    content = replace(
        content,
        "<!-- BEGIN:PINNED -->",
        "<!-- END:PINNED -->",
        ["## Pinned — recurring or high-cost scars", ""] + pinned if pinned
        else ["## Pinned — recurring or high-cost scars", "", "_(no pinned learnings yet)_"],
    )
    content = replace(
        content,
        "<!-- BEGIN:RECENT -->",
        "<!-- END:RECENT -->",
        ["## Recent — last 10 scars / patterns across all competitions", ""] + recent if recent
        else ["## Recent — last 10 scars / patterns across all competitions", "", "_(none yet)_"],
    )

    digest_path.write_text(content)


if __name__ == "__main__":
    main()
