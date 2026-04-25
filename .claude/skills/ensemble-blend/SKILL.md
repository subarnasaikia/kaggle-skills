---
name: ensemble-blend
description: Blend multiple Kaggle submission CSVs via weighted average (regression) or rank average (classification/ranking). Use when the user says "blend submissions", "ensemble these CSVs", "rank average", "weighted blend", or "combine my models".
---

# Ensemble Blend

Combines multiple submission CSVs into one blended submission. Rank averaging is robust to scale differences; weighted averaging preserves magnitude.

## When to use

- You have 2+ models with similar CV scores but different architectures (diversity → blend gain).
- CV/LB correlation is strong enough that you trust individual submissions.
- You want to reduce variance before a final submission.

## Rule of thumb

| Situation | Method |
|---|---|
| Regression, same scale | Weighted average |
| Classification (probabilities) | Weighted average |
| Mixed scales / different metrics | Rank average |
| Ranking / ordinal target | Rank average |
| You don't know relative model quality | Equal-weight rank average |

## Steps

### 1. Identify submission files to blend

```bash
ls competitions/<slug>/submissions/*.csv
```

Pick files with distinct architectures (LightGBM + XGBoost + NN blends better than 3×LightGBM).

### 2. Run the blend

```python
import pandas as pd
import numpy as np
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────────────
slug        = "<competition-slug>"
target_col  = "<prediction-column>"       # e.g. "Survived", "SalePrice"
id_col      = "<id-column>"               # e.g. "PassengerId", "Id"
blend_mode  = "rank"                      # "rank" | "weighted"

submissions = [
    ("competitions/<slug>/submissions/<file1>.csv", 1.0),
    ("competitions/<slug>/submissions/<file2>.csv", 1.0),
    ("competitions/<slug>/submissions/<file3>.csv", 1.0),
]
# For weighted mode, replace 1.0 with CV scores or manual weights.
# Weights are normalized automatically.

# ── Load ──────────────────────────────────────────────────────────────────────
dfs = []
for path, weight in submissions:
    df = pd.read_csv(path)
    assert id_col in df.columns, f"id column '{id_col}' missing in {path}"
    assert target_col in df.columns, f"target column '{target_col}' missing in {path}"
    dfs.append((df.set_index(id_col)[target_col], weight))

# Align on index
ids = dfs[0][0].index
for df, _ in dfs[1:]:
    assert df.index.equals(ids), "Row order / IDs differ between submissions — sort first"

# ── Blend ─────────────────────────────────────────────────────────────────────
if blend_mode == "rank":
    ranks  = [df.rank(pct=True) for df, _ in dfs]
    weights = np.array([w for _, w in dfs])
    weights /= weights.sum()
    blended = sum(r * w for r, w in zip(ranks, weights))

elif blend_mode == "weighted":
    weights = np.array([w for _, w in dfs])
    weights /= weights.sum()
    blended = sum(df * w for (df, _), w in zip(dfs, weights))

else:
    raise ValueError(f"Unknown blend_mode: {blend_mode}")

# ── Save ──────────────────────────────────────────────────────────────────────
from datetime import datetime, timezone
ts      = datetime.now(timezone.utc).strftime("%Y-%m-%d_%H%M")
out_csv = Path(f"competitions/{slug}/submissions/{ts}_blend_{blend_mode}.csv")
result  = blended.rename(target_col).reset_index()
result.to_csv(out_csv, index=False)
print(f"Saved: {out_csv}  ({len(result)} rows)")
print(result[target_col].describe().round(4))
```

### 3. Validate the output

```python
import pandas as pd
sample = pd.read_csv(f"competitions/{slug}/data/sample_submission.csv")
result = pd.read_csv(out_csv)

assert list(result.columns) == list(sample.columns), "Column mismatch vs sample_submission"
assert len(result) == len(sample), f"Row count mismatch: {len(result)} vs {len(sample)}"

# For binary classification: check predictions are in [0, 1]
if result[target_col].between(0, 1).all():
    print("Predictions in [0, 1] ✓")

print("Preview:")
print(result.head())
```

### 4. Submit

```bash
python3 shared/utils/submit.py <slug> <out_csv> "blend: <model-list> (<blend_mode>)"
```

## Tuning weights

If you want to optimize weights on CV:

```python
from scipy.optimize import minimize
import numpy as np

# preds_list: list of np.array of OOF predictions
# y_true: ground truth labels

def neg_score(weights, preds_list, y_true, metric_fn):
    weights = np.abs(weights) / np.abs(weights).sum()
    blended = sum(p * w for p, w in zip(preds_list, weights))
    return -metric_fn(y_true, blended)

result = minimize(
    neg_score,
    x0=[1.0 / len(preds_list)] * len(preds_list),
    args=(preds_list, y_true, <your_metric_fn>),
    method="Nelder-Mead",
)
optimal_weights = np.abs(result.x) / np.abs(result.x).sum()
print("Optimal weights:", np.round(optimal_weights, 3))
```

## Do NOT

- Don't blend submissions that haven't been individually validated (garbage in → garbage out).
- Don't blend more than ~5-7 models without checking for diversity — correlated models add noise, not signal.
- Don't use raw CV scores as weights without checking for CV/LB correlation first.
- Don't submit a blend without first running the validation in step 3.
