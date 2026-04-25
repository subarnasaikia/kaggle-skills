# <slug> — NLP Competition Rules

## Scoring
- Metric: <!-- e.g. F1 | ROUGE-L | accuracy | pearson-r -->
- Direction: <!-- higher-better | lower-better -->
- Local proxy: `sklearn.metrics.<fn>` or HuggingFace `evaluate`

## Submission
- Format: <!-- CSV with columns `id, label` | text generation | ranking -->
- Daily limit: <!-- N -->

## Data
- Train size: <!-- N rows -->
- Text column(s): <!-- list -->
- Label column: <!-- col name -->
- Language(s): <!-- English | multilingual | code -->
- Max token length: <!-- estimate from tokenizer -->

## Modeling approach
- Tokenizer: <!-- e.g. AutoTokenizer.from_pretrained("...") -->
- Backbone: <!-- e.g. deberta-v3-base | roberta-large | llama-3-8b -->
- Framework: <!-- HuggingFace Transformers | sentence-transformers | vLLM -->
- Compute: <!-- local GPU | Kaggle T4 | Kaggle A100 -->

## CV strategy
- Split: <!-- StratifiedKFold(5) | GroupKFold on topic | MultilabelStratified -->
- OOF predictions: save to `models/<version>/oof.npy`

## Kaggle notebook (if code competition)
- Notebook slug: `<username>/<notebook-slug>`
- Dataset sources: competition data + model weights uploaded as Kaggle Dataset
- Accelerator: `NvidiaTeslaT4` | `NvidiaTeslaA100` | `NvidiaL4`
- Internet: off (standard) | on (allowed competitions)

## Known quirks
- <!-- e.g. "labels are soft — use BCE not CE" -->
- <!-- e.g. "test has domain shift vs train — filter train by similarity" -->

## References
- Overview : https://www.kaggle.com/competitions/<slug>/overview
- Data     : https://www.kaggle.com/competitions/<slug>/data
