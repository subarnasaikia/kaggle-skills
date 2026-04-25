# kaggle-skills

A toolkit of Claude Code skills, hooks, and scripts that compound your Kaggle knowledge across competitions — designed so every session starts smarter than the last.

## What it does

- **Skills** — slash commands Claude invokes automatically: scaffold a competition, submit safely, run local eval, capture learnings, and more.
- **Hooks** — auto-inject your accumulated learnings at session start; nudge you to log experiments and review submissions.
- **Learning system** — a file-based memory that grows with you. Every scar, every validated pattern lives in `.learnings/`. Future sessions read it automatically.
- **Scripts** — `kln` CLI for humans to search, add, and archive learnings from the terminal.

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| [Claude Code](https://claude.ai/code) | latest | `npm i -g @anthropic-ai/claude-code` |
| [kaggle CLI](https://github.com/Kaggle/kaggle-api) | ≥ 2.0.1 | `uv tool install --python 3.11 kaggle` |
| [uv](https://github.com/astral-sh/uv) | latest | `curl -Lsf https://astral.sh/uv/install.sh | sh` |
| Python | ≥ 3.11 | via uv or system |
| git | any | system |

Kaggle auth: put your API token (a single `KGAT_…` line) in `~/.kaggle/access_token` with mode `600`.

```bash
chmod 600 ~/.kaggle/access_token
```

## Quick install — let Claude Code do it

Paste this prompt directly into Claude Code. It will clone the toolkit, ask whether you're adding it to an existing workspace or starting fresh, and set everything up for you.

```
Set up my Kaggle workspace with kaggle-skills.

Clone the toolkit:
  git clone --depth 1 https://github.com/subarnasaikia/kaggle-skills.git /tmp/kaggle-skills

Then ask me ONE question before doing anything else:
  "Do you have an existing Kaggle workspace directory, or do you want to create a new one?"

  → Existing workspace: ask for the path, then run:
      bash /tmp/kaggle-skills/install.sh <my-path>

  → New workspace: ask where to create it (suggest ~/kaggle as default), then run:
      bash /tmp/kaggle-skills/install.sh <chosen-path>

After the install finishes:
  1. Tell me where my workspace lives and confirm which files were copied.
  2. Add a kaggle-skills section to my global ~/.claude/CLAUDE.md so all future
     sessions know the skills are available:

     ## kaggle-skills
     Workspace: <workspace-path>
     Repo: https://github.com/subarnasaikia/kaggle-skills
     Skills: new-competition, submit-competition, run-local-eval, improve-agent,
             debug-agent, leaderboard-check, eda-audit, ensemble-blend,
             log-experiment, capture-learning, recall-learnings,
             preflight-consult, post-submission-review, retrospect-session.
     Ritual: recall-learnings before any non-trivial move. capture-learning when
             surprised. retrospect-session before closing the laptop.

  3. Ask me: "Do you want to open Claude Code in the workspace now?"
```

## Manual install (terminal)

```bash
# HTTPS (no SSH config needed)
git clone --depth 1 https://github.com/subarnasaikia/kaggle-skills.git /tmp/kaggle-skills

# Fresh workspace
bash /tmp/kaggle-skills/install.sh ~/kaggle

# OR — add to an existing workspace
bash /tmp/kaggle-skills/install.sh /path/to/your/existing/kaggle-workspace
```

The install script will:
1. Verify prerequisites (kaggle CLI, uv, python3, git).
2. Copy `.claude/`, `scripts/`, `shared/`, and template files.
3. Make all scripts executable.
4. Skip files that already exist (safe to re-run).
5. Print what to do next.

## Workspace layout after install

```
your-kaggle-workspace/
├── CLAUDE.md                  # Global rules (loaded by Claude Code automatically)
├── LEARNINGS.md               # Digest of top learnings (auto-updated)
├── .claude/
│   ├── settings.json          # Permissions + hook wiring
│   ├── hooks/
│   │   ├── session-start.sh   # Injects learnings at every session start
│   │   ├── post-kaggle-action.sh  # Post-submit nudge
│   │   └── stop.sh            # End-of-session retro nudge
│   └── skills/                # One folder per skill
├── .learnings/                # One file per learning (grows over time)
├── scripts/
│   └── kln                    # Human CLI for learnings
└── competitions/
    └── <slug>/                # One folder per competition
```

## Skills reference

### Core workflow
| Skill | What it does |
|---|---|
| `new-competition` | Scaffold a full competition folder with README, LOG, gitignore, venv prompt |
| `submit-competition` | Pre-flight validate + safe submit with quota check and LOG update |
| `leaderboard-check` | Pull leaderboard, compare your best score, show gap to medals |
| `post-submission-review` | Poll score, diff vs best, update LOG, capture learning if notable |

### Agents / simulation
| Skill | What it does |
|---|---|
| `run-local-eval` | Run kaggle-environments matches, report win rate and time budget |
| `improve-agent` | Systematic improvement loop: diagnose → hypothesize → implement → verify |
| `debug-agent` | Step through a replay, find the failing turn, print diagnostics |

### Tabular / ML
| Skill | What it does |
|---|---|
| `eda-audit` | Structured EDA: target dist, missing values, leakage scan, train/test shift |
| `ensemble-blend` | Weighted average or rank average across multiple submission CSVs |

### Learning system
| Skill | What it does |
|---|---|
| `log-experiment` | Write hypothesis before running; fill outcome after |
| `capture-learning` | Write a durable `.learnings/L-*.md` learning file |
| `recall-learnings` | Surface prior learnings relevant to the current task |
| `preflight-consult` | Sanity-check a plan against prior learnings before committing time |
| `retrospect-session` | Extract 0-3 learnings at session end, refresh LEARNINGS.md digest |

## The learning system

```
session starts → hooks inject top learnings into context
     ↓
Claude does work (plans, experiments, submits)
     ↓
surprise? → capture-learning   experiment? → log-experiment
submit?   → post-submission-review
     ↓
session ends → retrospect-session extracts durable lessons
     ↓
next session starts smarter
```

## Competition templates

`competitions/template/` — a fully scaffolded reference folder showing the expected structure and file formats. Use it as a reference when contributing or when `new-competition.sh` doesn't fit your needs.

`.claude/templates/` — per-competition-type `CLAUDE.md` starters. Copy the one that matches your competition into `competitions/<slug>/CLAUDE.md`:

| File | Competition type |
|---|---|
| `CLAUDE.tabular.md` | Tabular (LightGBM, XGBoost, feature engineering) |
| `CLAUDE.simulation.md` | Agent / simulation (kaggle-environments) |
| `CLAUDE.nlp.md` | NLP (text classification, generation, ranking) |
| `CLAUDE.cv.md` | Computer vision (classification, detection, segmentation) |
| `CLAUDE.notebook.md` | Code / notebook competitions (run on Kaggle's servers) |

## Shared utilities

| Script | What it does |
|---|---|
| `shared/utils/submit.py` | Python wrapper around `kaggle competitions submit` — pre-flight validates file, archives it with a timestamp, appends a row to `submissions/LOG.md`, then calls the CLI. Usable by both humans and Claude. |

```bash
# standard usage
python3 shared/utils/submit.py titanic submission.csv "lgbm baseline"

# skip the interactive y/N prompt (e.g. in scripts)
python3 shared/utils/submit.py titanic submission.csv "lgbm baseline" --yes
```

The script must be run from the workspace root (where `competitions/` lives). It reads `competitions/<slug>/data/sample_submission.csv` for the header check if present.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). New skills, bug fixes, and competition-type-specific patterns are all welcome.
