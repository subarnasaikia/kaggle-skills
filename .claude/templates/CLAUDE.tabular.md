# <slug> — Tabular Competition Rules

## Scoring
- Metric: <!-- e.g. AUC-ROC | RMSE | log-loss | F1 -->
- Direction: <!-- higher-better | lower-better -->
- Local proxy: `sklearn.metrics.<fn>(y_true, y_pred)`

## Submission
- Format: CSV with columns `<id_col>, <target_col>`
- Daily limit: <!-- N -->
- Validator: `python3 -c "import pandas as pd; df=pd.read_csv('submission.csv'); assert list(df.columns)==['<id>','<target>'], 'column mismatch'"`

## CV strategy
- Split: <!-- StratifiedKFold(n_splits=5) | KFold(5) | GroupKFold -->
- Stratify on: <!-- target | None -->
- Reason: <!-- why this split matches data structure -->

## Stack decisions
- Baseline: <!-- LightGBM | XGBoost | CatBoost | sklearn -->
- Feature engineering: <!-- TBD -->
- Ensemble plan: <!-- TBD -->

## Data notes
- ID column: `<col>` — exclude from features, cast to int before writing.
- Target column: `<col>`
- Categorical columns: <!-- list -->
- DateTime columns: <!-- list — parse and extract features -->
- High-cardinality columns: <!-- list — consider target encoding -->

## Known quirks
- <!-- e.g. "test set has different class distribution — weight by adversarial validation" -->

## References
- Overview : https://www.kaggle.com/competitions/<slug>/overview
- Data     : https://www.kaggle.com/competitions/<slug>/data
