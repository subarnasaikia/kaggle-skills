---
name: new-competition
description: Scaffold a new Kaggle competition subfolder under competitions/<slug>/ with CLAUDE.md, README, gitignore, submission log, and standard subdirs. Use when the user says "new competition", "start <slug>", "scaffold <slug>", or provides a Kaggle competition URL.
---

# Scaffolding a New Kaggle Competition

## Inputs

The user provides one of:
- Competition slug (e.g. `titanic`, `lmsys-chatbot-arena`).
- Kaggle URL (e.g. `https://www.kaggle.com/competitions/titanic/overview`).

Extract `<slug>` from the URL segment after `/competitions/`.

## Required steps

1. **Resolve workspace root.** Look for `CLAUDE.md` + `.claude/` + `.learnings/` by walking up from cwd. If not found, ask the user for the workspace path.
2. **Check for existing folder.** If `competitions/<slug>/` already exists, ask user whether to overwrite or cd into it.
3. **Fetch competition metadata.** Prefer Kaggle MCP tools. CLI fallbacks:
   - Fuzzy search (if slug is uncertain): `kaggle competitions list -s <term>`
   - List data files without downloading: `kaggle competitions files <slug>`
   Capture:
   - Title
   - Scoring metric + direction (higher-better / lower-better)
   - Submission file format (csv, notebook, agent.py, etc.)
   - Submission daily limit
   - Evaluation time limit (for simulation competitions)
   - Data file list (don't download yet)
   - Deadline
4. **Create directory skeleton:**
   ```
   competitions/<slug>/
   ├── CLAUDE.md             # competition-specific rules
   ├── README.md
   ├── LEARNINGS.md          # competition-scoped learnings
   ├── .gitignore
   ├── data/                 # gitignored
   ├── agents/               # or models/ for tabular
   ├── notebooks/
   ├── replays/              # gitignored; for simulation competitions
   ├── experiments/
   │   └── EXPERIMENTS.md
   └── submissions/
       └── LOG.md
   ```
5. **Write `competitions/<slug>/CLAUDE.md`** with competition-specific rules:
   - Scoring metric + how to optimize it locally
   - Submission format + validator command
   - Daily submission limit + "never auto-submit" rule
   - Evaluation time budget (if agent-based)
   - Known gotchas from overview/rules page
6. **Write `competitions/<slug>/README.md`** with:
   - Competition title + link
   - One-paragraph summary
   - Metric, format, deadline
   - Quick start: how to download data, run local eval, submit
7. **Write `competitions/<slug>/submissions/LOG.md`** header:
   ```
   # Submission Log — <competition-title>

   | Date | File | Message | Public Score | Notes |
   |------|------|---------|--------------|-------|
   ```
8. **Write `competitions/<slug>/experiments/EXPERIMENTS.md`** header (see `log-experiment` skill for format).
9. **Write `competitions/<slug>/LEARNINGS.md`** header (see `.learnings/README.md` for format).
10. **Write `competitions/<slug>/.gitignore`**:
    ```
    data/
    .venv/
    replays/
    submissions/*.csv
    submissions/*.zip
    __pycache__/
    *.pkl
    *.pt
    ```
11. **Bootstrap Python env** (only if user confirms):
    ```bash
    cd competitions/<slug>
    uv venv --python 3.11
    uv pip install kaggle kaggle-environments pandas numpy
    ```
12. **Pin the default competition** so bare `kaggle competitions <cmd>` resolves to this slug:
    ```bash
    kaggle config set -n competition -v <slug>
    ```
    Use `kaggle config unset -n competition` to clear when switching. CLI 2.x requires `-n`/`-v` flags.
13. **Print summary** to user:
    - Folder created
    - Metadata captured (metric, format, deadline)
    - Next suggested step: "Download data? y/n"
    - Do NOT auto-download.

## Do NOT

- Do not download data during scaffolding.
- Do not submit anything.
- Do not create the venv unless user confirms.
- Do not populate `agents/` with starter code unless asked.

## Sub-type hints

**Simulation / agent competition:**
- Use `agents/` folder with versioned subfolders (`v1_baseline/`, `v2_search/` …).
- Add `agents/baseline/agent.py` only if user asks.
- Mention `kaggle-environments` in README.
- Note time-per-turn budget in CLAUDE.md.

**Tabular competition:**
- Use `models/` folder.
- Mention sklearn / xgboost / lightgbm in README only if user asks for a stack.

**Notebook-based submission:**
- Mention `create_code_competition_submission` MCP tool in CLAUDE.md.
- Point submission workflow to notebook versioning.

**NLP / CV competition:**
- Add `models/` for checkpoints (gitignored if > 50 MB).
- Note GPU constraints if running locally vs. Kaggle-hosted.
