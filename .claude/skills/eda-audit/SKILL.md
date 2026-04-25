---
name: eda-audit
description: Structured EDA audit for tabular competitions — target distribution, missing values, leakage scan, class imbalance, feature types, outliers, train/test shift. Use when the user says "do EDA", "audit the data", "explore the dataset", "check for leakage", or when starting a new tabular competition.
---

# EDA Audit — Tabular Competition

Systematic first-look at a competition dataset. Produces a structured report so you know what you're working with before touching a model.

## When to use

- First time you touch a new competition's data.
- Before designing a CV strategy (need to know if data is temporal, grouped, etc.).
- When CV/LB mismatch appears (often a leakage or distribution issue).
- When a model has unexpectedly high or low performance.

## Setup

```bash
cd competitions/<slug>
source .venv/bin/activate  # or: uv run python3
```

All snippets assume `train`, `test`, `target_col` are already set.

## Step 1 — Shape and dtypes

```python
import pandas as pd
train = pd.read_csv("data/train.csv")
test  = pd.read_csv("data/test.csv")
target_col = "<target>"   # fill this in

print("Train:", train.shape, "  Test:", test.shape)
print(train.dtypes.value_counts())
print(train.head(3))
```

Flag: if train has columns that test doesn't (or vice versa), list them — that's your feature set boundary.

## Step 2 — Target distribution

```python
import matplotlib.pyplot as plt

y = train[target_col]
print(y.describe())
print("Nulls:", y.isna().sum())

if y.dtype == object or y.nunique() < 20:          # classification
    print(y.value_counts(normalize=True).round(3))
    imbalance_ratio = y.value_counts().iloc[0] / y.value_counts().iloc[-1]
    if imbalance_ratio > 10:
        print(f"WARNING: class imbalance ratio {imbalance_ratio:.1f}x — consider stratified CV")
else:                                               # regression
    y.hist(bins=50)
    plt.title("Target distribution")
    plt.savefig("notebooks/eda_target.png")
    print("Skew:", y.skew().round(3))
    if abs(y.skew()) > 1:
        print("WARNING: high skew — consider log1p transform")
```

## Step 3 — Missing values

```python
miss_train = (train.isna().mean() * 100).sort_values(ascending=False)
miss_test  = (test.isna().mean() * 100).sort_values(ascending=False)

high_miss = miss_train[miss_train > 30]
if not high_miss.empty:
    print("Columns >30% missing in train:")
    print(high_miss.round(1))

# Columns missing in test but not train (or vice versa) — potential shift
asymmetric = set(miss_train[miss_train > 0].index) ^ set(miss_test[miss_test > 0].index)
if asymmetric:
    print("Asymmetric missing columns:", asymmetric)
```

## Step 4 — Leakage scan

```python
# High correlation with target — suspicious if > 0.99
num_cols = train.select_dtypes("number").columns.difference([target_col])
corr = train[num_cols].corrwith(train[target_col]).abs().sort_values(ascending=False)
leaky = corr[corr > 0.95]
if not leaky.empty:
    print("POTENTIAL LEAKAGE — correlation with target > 0.95:")
    print(leaky)

# Columns that contain the word "target", "label", "score", "result"
suspicious_names = [c for c in train.columns if any(
    kw in c.lower() for kw in ["target", "label", "score", "result", "answer"]
) and c != target_col]
if suspicious_names:
    print("Suspicious column names:", suspicious_names)
```

## Step 5 — Cardinality and feature types

```python
cat_cols = train.select_dtypes("object").columns.tolist()
num_cols = train.select_dtypes("number").columns.difference([target_col]).tolist()

# High-cardinality categoricals
for c in cat_cols:
    n = train[c].nunique()
    if n > 100:
        print(f"High-cardinality: {c} ({n} unique) — consider target encoding or embedding")
    elif n == train.shape[0]:
        print(f"Unique per row: {c} — likely an ID column, exclude from features")

# Potential datetime columns hiding as strings
for c in cat_cols:
    sample = train[c].dropna().iloc[0] if not train[c].dropna().empty else ""
    if any(p in str(sample) for p in ["-", "/"]) and any(c2 in c.lower() for c2 in ["date", "time", "dt", "year"]):
        print(f"Potential datetime: {c} — parse with pd.to_datetime and extract features")
```

## Step 6 — Duplicate rows

```python
dups = train.duplicated().sum()
if dups > 0:
    print(f"WARNING: {dups} duplicate rows in train ({dups/len(train):.1%})")

# Duplicates between train and test (by non-target columns)
shared_cols = [c for c in train.columns if c in test.columns and c != target_col]
overlap = pd.merge(train[shared_cols], test[shared_cols], how="inner")
if not overlap.empty:
    print(f"WARNING: {len(overlap)} rows appear in both train and test — potential leakage")
```

## Step 7 — Train/test distribution shift

```python
from scipy.stats import ks_2samp

shift_cols = []
for c in num_cols:
    if c in test.columns:
        stat, p = ks_2samp(train[c].dropna(), test[c].dropna())
        if p < 0.01:
            shift_cols.append((c, round(stat, 3), round(p, 4)))

if shift_cols:
    print("Columns with significant train/test distribution shift (KS p<0.01):")
    for col, stat, p in sorted(shift_cols, key=lambda x: -x[1])[:10]:
        print(f"  {col:40s}  KS={stat}  p={p}")
```

## Step 8 — CV strategy recommendation

Based on findings above, recommend:

| Finding | Recommended CV strategy |
|---|---|
| Time-ordered `date` column | Time-series split (no shuffle) |
| `user_id` / `group_id` present | GroupKFold on that column |
| Class imbalance > 5x | StratifiedKFold |
| High train/test shift | Adversarial validation to weight train rows |
| Standard tabular, no grouping | StratifiedKFold (classification) or KFold (regression) |

## Output — EDA report

Summarize findings in one block:

```
EDA Audit: <competition-slug>
  Train shape     : (N, F)   Test: (M, F-1)
  Target          : <col> — <regression|classification, N classes>
  Class imbalance : <ratio or N/A>
  Missing values  : <max % column>, <N columns > 10%>
  Leakage flags   : <column names or "none">
  Shift columns   : <N columns with KS p<0.01>
  High cardinality: <column names or "none">
  Recommended CV  : <strategy>
  Next step       : <what to tackle first>
```

Invoke `capture-learning` if you find a non-obvious quirk (leakage, weird dtype, severe shift) that future sessions should know about.
