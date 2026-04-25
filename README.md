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

## Quick install

```bash
git clone git@github.com:subarnasaikia/kaggle-skills.git ~/kaggle
cd ~/kaggle
bash install.sh
```

The install script will:
1. Verify prerequisites.
2. Copy `.claude/`, `scripts/`, and template files into the workspace.
3. Make scripts executable.
4. Print what to do next.

## Manual install

If you already have a Kaggle workspace:

```bash
# Copy skills + hooks into your workspace
cp -r .claude/ /path/to/your/kaggle-workspace/
cp -r scripts/ /path/to/your/kaggle-workspace/
cp LEARNINGS.md /path/to/your/kaggle-workspace/
cp CLAUDE.md /path/to/your/kaggle-workspace/
chmod +x /path/to/your/kaggle-workspace/scripts/kln
chmod +x /path/to/your/kaggle-workspace/scripts/new-competition.sh
```

Then edit `CLAUDE.md` to set your workspace root path in the hooks config.

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
