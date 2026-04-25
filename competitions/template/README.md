# <competition-title>

> This is the **template folder**. Copy it to `competitions/<slug>/` and fill in the blanks.
> `scripts/new-competition.sh <slug>` does this automatically.

Kaggle competition: https://www.kaggle.com/competitions/<slug>

## Summary

<!-- One paragraph: what is the task, what is the data, what makes it interesting or hard. -->

## Metric

<!-- e.g. Area Under the ROC Curve (AUC). Higher is better. -->

## Submission format

<!-- e.g. CSV with columns `Id,Survived`. Must match sample_submission.csv exactly. -->

## Deadline

<!-- e.g. 2026-06-30 -->

## Quick start

```bash
# list files before pulling
kaggle competitions files <slug>

# download data (no --unzip for competitions; unzip manually)
kaggle competitions download <slug> -p data/
cd data && unzip -o "*.zip" && cd ..

# pin default competition
kaggle config set -n competition -v <slug>

# run EDA audit
# invoke the eda-audit skill in Claude Code

# submit (standard file)
python3 ../../shared/utils/submit.py <slug> submission.csv "baseline"

# view submissions
kaggle competitions submissions <slug>

# leaderboard
kaggle competitions leaderboard <slug> --show
```

## Structure

```
competitions/<slug>/
├── CLAUDE.md           # scoring metric, CV strategy, known quirks
├── README.md           # this file
├── LEARNINGS.md        # competition-scoped learnings (auto-loaded)
├── .gitignore
├── data/               # gitignored — download here
├── agents/             # for simulation competitions (versioned subfolders)
├── models/             # for tabular/ML competitions (versioned subfolders)
├── notebooks/          # EDA, experiments
├── replays/            # gitignored — local eval replays
├── experiments/
│   └── EXPERIMENTS.md  # hypothesis → outcome ledger
└── submissions/
    └── LOG.md          # every submission with score + notes
```
