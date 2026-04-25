# <competition-title> — Competition Rules

> Copy this file to `competitions/<slug>/CLAUDE.md` and fill in the blanks.
> Delete this note block when done.

## Scoring
- Metric: <!-- e.g. AUC, RMSE, log-loss, win-rate -->
- Direction: <!-- higher-better | lower-better -->
- Local proxy: <!-- how to compute the same metric locally -->

## Submission
- Format: <!-- CSV with columns X,Y | agent.py | notebook -->
- Daily limit: <!-- e.g. 5 -->
- Local validator command: <!-- e.g. python3 scripts/validate.py submission.csv -->

## Time / resource constraints
- <!-- For agent competitions: per-turn budget, e.g. "500 ms/turn; stay under 400 ms" -->
- <!-- For notebook competitions: GPU hours, RAM limit -->
- <!-- For tabular: no runtime constraint -->

## CV strategy
- <!-- e.g. StratifiedKFold(n_splits=5) | GroupKFold on user_id | TimeSeriesSplit -->
- <!-- Reason: <why this split matches the data structure> -->

## Known quirks
- <!-- Fill as you discover them; capture-learning will add them to .learnings/ too -->

## References
- Overview : https://www.kaggle.com/competitions/<slug>/overview
- Rules    : https://www.kaggle.com/competitions/<slug>/rules
- Data     : https://www.kaggle.com/competitions/<slug>/data
