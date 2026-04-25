# Kaggle Workspace — Global Instructions

This file is automatically loaded by Claude Code at every session. It applies to all competitions under this workspace.

## Workspace Layout

```
<workspace-root>/
├── CLAUDE.md              # This file — global rules
├── LEARNINGS.md           # Global learning digest (auto-updated)
├── .claude/
│   ├── settings.json      # Project-scoped permissions + hooks
│   └── skills/            # Kaggle-specific skills
├── competitions/          # One subfolder per competition
│   └── <slug>/
│       ├── CLAUDE.md      # Competition-specific rules
│       ├── data/          # gitignored
│       ├── agents/        # or models/ for tabular
│       ├── notebooks/
│       ├── submissions/
│       │   └── LOG.md
│       ├── experiments/
│       │   └── EXPERIMENTS.md
│       └── replays/
├── scripts/               # Cross-competition helpers
├── .learnings/            # One file per learning
└── .gitignore
```

## Non-Negotiable Rules

### Credentials
- Auth token lives at `~/.kaggle/access_token` (mode 600). Never print it.
- CLI reads the file first, then falls back to `KAGGLE_API_TOKEN` env var.
- Legacy `kaggle.json` is NOT used. Replace any reference to it with the access-token flow.
- Never commit tokens, `.env` files, or `access_token` to git.

### Data handling
- Competition data belongs in `competitions/<slug>/data/` — gitignored.
- Never re-download if already present. Check `data/` first.
- Respect competition data-use terms. Do not upload competition data to third-party services.

### Submissions
- **Never submit without explicit user confirmation.** Submissions burn daily quota.
- Every submission file must be archived under `competitions/<slug>/submissions/` with a timestamp.
- Record leaderboard score + message in `competitions/<slug>/submissions/LOG.md` after every submit.
- Run local evaluation before submitting (if an eval harness exists).

### Agent code (simulation competitions)
- Agents must be deterministic given a seed. Log the seed for every self-play run.
- Validate moves against the environment's action space before returning.
- Time-per-move budget must be respected — stay at least 20% under the limit by default.
- The `def agent(obs):` function must be the **last** top-level `def` in the file (kaggle-environments picks the last one).

### General engineering
- Python: prefer `uv` for environments (`uv venv`, `uv pip`).
- One virtualenv per competition, at `competitions/<slug>/.venv/` — gitignored.
- Use `kaggle-environments` for local simulation testing before submitting.

## Shared Utilities

`shared/utils/submit.py` is a Python wrapper around `kaggle competitions submit`. Use it instead of calling the CLI directly when you want:
- Automatic CSV header validation against `sample_submission.csv`
- Timestamped archival copy in `competitions/<slug>/submissions/`
- Auto-appended row in `submissions/LOG.md`

```bash
# from workspace root
python3 shared/utils/submit.py <slug> <file> "<message>"
python3 shared/utils/submit.py <slug> <file> "<message>" --yes  # skip confirm
```

The `submit-competition` skill orchestrates the full flow and calls this script as part of it.

## CLI Syntax Source of Truth

**Before emitting any `kaggle ...` command, consult `.claude/KAGGLE_CLI_CHEATSHEET.md`.** If a skill or script disagrees with the cheat sheet, the cheat sheet wins.

## Self-Improvement — The Learning System

### Mandatory rituals

1. **SessionStart** auto-loads `LEARNINGS.md` + competition-scoped learnings + last 5 submissions. No action needed — wired in hooks.
2. **Before any non-trivial move**, invoke `recall-learnings`. Cite relevant learning IDs in your plan.
3. **When you hit a surprise**, invoke `capture-learning` immediately — while the cause is fresh.
4. **Before running any experiment**, invoke `log-experiment` — write the hypothesis before the result.
5. **After every `kaggle competitions submit`**, the PostToolUse hook nudges `post-submission-review`. Run it.
6. **At session end**, the Stop hook nudges `retrospect-session`. Run it.

### Where things live

| Where | What |
|---|---|
| `LEARNINGS.md` | Global digest (auto-loaded) — Pinned + Recent. Keep < 60 lines. |
| `.learnings/L-*.md` | One learning per file — the full corpus. |
| `.learnings/archive/` | Obsolete learnings, kept for history. |
| `competitions/<slug>/LEARNINGS.md` | Competition-scoped lessons (auto-loaded in-folder). |
| `competitions/<slug>/experiments/EXPERIMENTS.md` | Hypothesis → outcome ledger. |
| `competitions/<slug>/submissions/LOG.md` | Every submission + score + note. |
| `scripts/kln` | Human CLI: `add`, `list`, `show`, `search`, `tags`, `digest`, `archive`. |

### The discipline in one line

**Recall before you act. Capture when you're surprised. Retrospect before you close the laptop.**

## Which tool to use

See `.claude/MCP_VS_CLI_GUIDE.md`. Short version:
- **CLI** — file transfers, submissions, bulk listings, automation. Default.
- **MCP** — small targeted lookups ("what's the metric", "top-5 competitions").
- **kagglehub** — inside Python code that loads datasets/models at runtime.

## Workflow Patterns

- **Exploration** — EDA in `competitions/<slug>/notebooks/`.
- **Iteration** — each meaningful change gets its own versioned subfolder under `agents/` (e.g. `v1_baseline/`, `v2_search/`). One hypothesis per version.
- **Submit cadence** — dry-run → local eval → commit → submit. Never skip steps.
- **Post-submit** — always update `submissions/LOG.md` with timestamp, file, message, score, notes.

## What NOT To Do

- Don't commit raw competition data, model weights > 50 MB, or credentials.
- Don't modify `~/.kaggle/kaggle.json` or shell PATH without asking the user.
- Don't submit without the user explicitly asking. Submissions burn daily quota.
- Don't use `pip install` globally — scope every dep to a competition's `.venv`.
- Don't scrape Kaggle pages when the MCP server or CLI has the same data.
