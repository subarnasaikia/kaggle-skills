#!/usr/bin/env bash
# Scaffold a new Kaggle competition folder.
# Usage: scripts/new-competition.sh <slug>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <competition-slug>" >&2
  exit 1
fi

slug="$1"
root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$root/competitions/$slug"

if [[ -d "$dir" ]]; then
  echo "already exists: $dir" >&2
  exit 1
fi

mkdir -p "$dir"/{data,agents,notebooks,submissions,replays,experiments}

cat > "$dir/.gitignore" <<EOF
data/
.venv/
replays/
submissions/*.csv
submissions/*.zip
__pycache__/
*.pkl
*.pt
EOF

cat > "$dir/README.md" <<EOF
# $slug

Kaggle competition: https://www.kaggle.com/competitions/$slug

## Structure
- \`data/\` — competition data (gitignored)
- \`agents/\` — agent implementations (one subfolder per version; or use \`models/\` for tabular)
- \`notebooks/\` — EDA and experiments
- \`submissions/\` — archived submission files + LOG.md
- \`replays/\` — local eval replays (gitignored)
- \`experiments/\` — hypothesis ledger

## Quick start
\`\`\`bash
# list files before pulling
kaggle competitions files $slug

# download all data (no --unzip for competitions; unzip manually)
kaggle competitions download $slug -p data/ && (cd data && unzip -o "*.zip")

# pin default competition (lets you drop the slug in later commands)
kaggle config set -n competition -v $slug

# local eval (agent competitions)
python3 -c "from kaggle_environments import make; env = make('$slug', debug=True); print(env.run(['agents/baseline/agent.py', 'agents/baseline/agent.py']))"

# submit (standard)
kaggle competitions submit $slug -f submission.csv -m "<message>"

# submit (code / notebook competition)
kaggle competitions submit $slug -k <user>/<notebook> -v <ver> -f submission.csv -m "<message>"

# view submissions
kaggle competitions submissions $slug

# leaderboard
kaggle competitions leaderboard $slug --show
\`\`\`
EOF

cat > "$dir/CLAUDE.md" <<EOF
# $slug — Competition Rules

## Scoring
- Metric: TBD (fill after reading competition overview)
- Direction: higher-better | lower-better

## Submission
- Format: TBD
- Daily limit: TBD
- Local validator: TBD

## Known quirks
- TBD

## References
- Overview: https://www.kaggle.com/competitions/$slug/overview
- Rules: https://www.kaggle.com/competitions/$slug/rules
- Data: https://www.kaggle.com/competitions/$slug/data
EOF

cat > "$dir/submissions/LOG.md" <<EOF
# Submission Log — $slug

| Date | File | Message | Public Score | Notes |
|------|------|---------|--------------|-------|
EOF

cat > "$dir/LEARNINGS.md" <<EOF
# Learnings — $slug

Competition-scoped lessons that do not generalize to other Kaggle work. Auto-loaded at session start by the \`SessionStart\` hook when working inside this folder. Global learnings live at \`../../LEARNINGS.md\` and the full corpus at \`../../.learnings/\`.

## Competition-specific rules
_(filled in as Claude captures learnings tagged with \`scope: $slug\`)_

## Metric quirks
_(e.g. "this metric is sensitive to X; CV must stratify by Y")_

## Submission format gotchas
_(e.g. "dtype of ID column must be int, not float")_

## Time / resource constraints
_(e.g. "per-turn budget 500ms; stay under 400ms to be safe")_
EOF

cat > "$dir/experiments/EXPERIMENTS.md" <<EOF
# Experiments — $slug

Hypothesis → setup → outcome → lesson ledger. Appended to by the \`log-experiment\` skill.

Format per entry:
- **ID / date / branch-or-commit**
- **Hypothesis** — predict direction + magnitude before running
- **Setup** — what's different from baseline; reproducible
- **Priors** — relevant learning IDs (from recall-learnings)
- **Outcome** — CV / LB numbers
- **Lesson** — one sentence: what updated in our mental model

---
EOF

echo "created: $dir"
echo "next: fill in $dir/CLAUDE.md, then download data"
