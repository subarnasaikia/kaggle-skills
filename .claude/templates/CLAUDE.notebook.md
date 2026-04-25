# <slug> — Notebook / Code Competition Rules

## Scoring
- Metric: <!-- e.g. accuracy | AUC | BLEU -->
- Direction: <!-- higher-better | lower-better -->
- Evaluated: <!-- on Kaggle's servers after notebook run -->

## Submission
- Type: Code competition — notebook runs on Kaggle, output is scored automatically.
- Notebook slug: `<your-kaggle-username>/<notebook-slug>`
- Output file: `submission.csv` (must be written to `/kaggle/working/`)
- Daily limit: <!-- N -->
- Runtime limit: <!-- e.g. 9 hours -->

## Notebook workflow

```bash
# 1. Pull local editable copy
kaggle kernels pull <username>/<notebook-slug> -m -p notebooks/<slug>

# 2. Edit notebook and kernel-metadata.json locally

# 3. Push to trigger a run
kaggle kernels push -p notebooks/<slug> [--accelerator NvidiaTeslaT4] [--timeout 32400]

# 4. Poll status
kaggle kernels status <username>/<notebook-slug>

# 5. Fetch outputs
kaggle kernels output <username>/<notebook-slug> -p notebooks/<slug>/out/ -o

# 6. Submit the notebook run
kaggle competitions submit <slug> \
  -k <username>/<notebook-slug> -v <version> \
  -f submission.csv -m "<message>"
```

Or via MCP: `create_code_competition_submission`.

## Kernel metadata must include
- `competition_sources: ["<slug>"]`
- `enable_internet: false` (standard) or `true` (if allowed)
- `accelerator` matching the competition's available hardware

## Dataset dependencies (model weights, external data)
- Upload as a private Kaggle Dataset: `kaggle datasets create -p <dir>`
- Reference in `kernel-metadata.json` under `dataset_sources`
- Path inside notebook: `/kaggle/input/<dataset-slug>/`

## Internet access
- <!-- off: no pip install inside notebook; freeze deps in a requirements dataset -->
- <!-- on: pip install allowed; still prefer pinned versions -->

## Accelerator
- Available: <!-- NvidiaTeslaT4 | NvidiaL4 | NvidiaH100 | TpuV5E8 — check competition page -->
- Default for this comp: <!-- fill in -->

## Known quirks
- <!-- e.g. "output must be named exactly 'submission.csv' — not 'sub.csv'" -->
- <!-- e.g. "GPU memory limit 16 GB — batch size > 32 OOMs" -->

## References
- Overview  : https://www.kaggle.com/competitions/<slug>/overview
- Notebook  : https://www.kaggle.com/<username>/<notebook-slug>
