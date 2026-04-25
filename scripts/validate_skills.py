#!/usr/bin/env python3
"""Validate that every .claude/skills/*/SKILL.md has required frontmatter fields.

Exit 0 if all pass. Exit 1 and print errors if any fail.
Run from the repo root: python3 scripts/validate_skills.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REQUIRED_FIELDS = {"name", "description"}
SKILLS_DIR = Path(".claude/skills")


def parse_frontmatter(text: str) -> dict[str, str]:
    m = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            k, _, v = line.partition(":")
            out[k.strip()] = v.strip()
    return out


def main() -> int:
    skill_files = sorted(SKILLS_DIR.glob("*/SKILL.md"))
    if not skill_files:
        print(f"WARNING: no skill files found under {SKILLS_DIR}")
        return 0

    errors: list[str] = []
    for path in skill_files:
        text = path.read_text()
        meta = parse_frontmatter(text)

        if not meta:
            errors.append(f"{path}: missing frontmatter block (--- ... ---)")
            continue

        missing = REQUIRED_FIELDS - meta.keys()
        if missing:
            errors.append(f"{path}: missing fields {sorted(missing)}")

        if "name" in meta and not meta["name"].strip():
            errors.append(f"{path}: 'name' field is empty")

        if "description" in meta and not meta["description"].strip():
            errors.append(f"{path}: 'description' field is empty")

        # Description should be meaningful (>20 chars) so it actually triggers Claude
        if "description" in meta and len(meta["description"]) < 20:
            errors.append(f"{path}: 'description' is too short (<20 chars) — Claude won't trigger on it reliably")

    if errors:
        print(f"Skill validation FAILED — {len(errors)} error(s):\n")
        for e in errors:
            print(f"  ✗  {e}")
        return 1

    print(f"Skill validation passed — {len(skill_files)} skills ok.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
