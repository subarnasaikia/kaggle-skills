# Learnings — The "Scar Tissue" System

This directory is the long-term memory of everything that bit us during Kaggle work, what we did about it, and what to check next time. **It is the mechanism that turns each session into compound interest.**

## Why this exists

Without this, every new session starts blank. You re-explain your preferences, your stack, past mistakes. Claude repeats earlier failures because nothing persists.

With this, Claude reads the relevant learnings at session start, consults them before making choices, and writes new ones when it learns something — all without you manually curating.

## Types of artifacts

| File/folder | What it holds | Who writes it |
|---|---|---|
| `.learnings/L-*.md` | One self-contained learning per file (scar, rule, how to apply, tags) | Claude via `capture-learning` skill, or you via `scripts/kln add` |
| `LEARNINGS.md` (repo root) | Curated digest of the highest-impact global learnings | You + Claude via `retrospect-session` |
| `competitions/<slug>/LEARNINGS.md` | Competition-specific lessons that don't generalize | Per-competition retrospection |
| `competitions/<slug>/experiments/EXPERIMENTS.md` | Hypothesis → outcome ledger for each experiment | `log-experiment` skill |
| `competitions/<slug>/submissions/LOG.md` | Every submission with score + lesson | `post-submission-review` skill |

## Learning file format

```markdown
---
id: L-YYYY-MM-DD-NNN
date: YYYY-MM-DD
scope: global | <competition-slug>
tags: [tag1, tag2, ...]
severity: scar | pattern | note
cost: low | medium | high
recurring: true | false
---

## Rule
<one-line actionable principle>

## Scar (what bit us)
<concrete event or observation>

## How to apply
- <check X before doing Y>
- <when you see Z, prefer W>

## Related
- L-XXXX (optional cross-references)
```

### Field definitions

- **id** — timestamp + seq so files sort chronologically.
- **scope** — `global` applies everywhere; a slug scopes to that competition only.
- **tags** — use stable families: `{agent-timeout, class-imbalance, leakage, cv-mismatch, hyperparam, feature-eng, submission-format, data-loading, env-setup, api-quirk}`. Add one to three. Prefer reuse over invention.
- **severity** — `scar`: cost a submission slot or hour+ of debugging; `pattern`: validated-good practice; `note`: mild gotcha.
- **cost** — rough hit: `low` < 1h, `medium` 1–8h, `high` > 8h or burned a daily submission slot.
- **recurring** — `true` once the same root cause has bitten us twice. Recurring learnings get pinned in `LEARNINGS.md`.

## How it flows

```
        session starts
              │
              ▼
   SessionStart hook reads the scope of cwd,
   surfaces top-N relevant learnings into context
              │
              ▼
      Claude does work (plans, edits, trains, submits)
              │
              ▼
   Bump into something surprising? → capture-learning skill
   Run an experiment?              → log-experiment skill
   Submit?                         → post-submit hook → post-submission-review
   Session ending?                 → Stop hook nudges retrospect-session
              │
              ▼
   New learnings written to .learnings/
   LEARNINGS.md digest updated periodically
              │
              ▼
        next session: reads compounded context
```

## Invariants

- **Never silently overwrite a learning.** Supersede it with a new one that links back.
- **Prune, don't delete.** If a learning becomes obsolete, move it to `.learnings/archive/` with a reason.
- **Keep each learning < 20 lines.** If it needs more, it's probably two learnings or a doc.
- **No secrets, no tokens, no PII.** This directory may be read by future Claude sessions.
