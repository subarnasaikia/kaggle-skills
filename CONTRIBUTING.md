# Contributing to kaggle-skills

Contributions welcome — new skills, bug fixes, hook improvements, and competition-type-specific patterns all make this toolkit better for everyone.

## What to contribute

- **New skills** — competition patterns you find yourself repeating (e.g. `debug-agent`, `eda-audit`, `ensemble-blend`).
- **Skill improvements** — more precise steps, better checklists, edge case handling.
- **Hook improvements** — smarter session-start context, better nudge heuristics.
- **Bug fixes** — wrong CLI flags, broken shell paths, stale command syntax.
- **New reference docs** — cheat sheets for libraries, frameworks, competition types.

## Skill anatomy

A skill is a single `SKILL.md` file under `.claude/skills/<name>/`. Claude Code loads it via the `Skill` tool.

```markdown
---
name: skill-name
description: One-sentence description that tells Claude WHEN to invoke this skill.
---

# Skill Title

## When to use
...

## Steps
1. ...
2. ...

## Do NOT
...
```

Rules for a good skill:
- The `description` frontmatter is the trigger — write it so Claude's pattern-matcher fires at the right moment.
- Steps must be numbered and concrete. No vague "review the situation" steps.
- Include a **Do NOT** section for the most common misuses.
- Keep it under ~100 lines. If longer, split into two skills.

## How to add a new skill

```bash
mkdir .claude/skills/my-new-skill
# write .claude/skills/my-new-skill/SKILL.md
```

Then add it to the `## Skills reference` table in `README.md`.

## CLI syntax source of truth

Every `kaggle ...` command must match `.claude/KAGGLE_CLI_CHEATSHEET.md`. If the CLI changes, update the cheat sheet first, then reconcile skills.

- Slug is **positional** in CLI ≥ 2.0.0 — no `-c` flag.
- `--unzip` exists on `datasets download` and `models variations versions download`, but **not** on `competitions download`.

## Submitting a pull request

1. Fork the repo.
2. Create a branch: `git checkout -b feat/my-skill` or `fix/broken-flag`.
3. Make your changes.
4. Test: open Claude Code in a real Kaggle workspace and exercise the skill end-to-end.
5. Open a PR with:
   - What the skill does (or what was broken).
   - How you tested it.
   - Competition type it targets (global / tabular / simulation / NLP / CV / notebook).

## Reporting issues

Open a GitHub issue with:
- The skill or hook that misbehaved.
- What you expected vs. what happened.
- Your kaggle CLI version (`kaggle --version`).
- Your Claude Code version (`claude --version`).
