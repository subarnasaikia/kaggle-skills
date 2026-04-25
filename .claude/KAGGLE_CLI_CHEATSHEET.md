# Kaggle CLI 2.0.1 — Syntax Cheat Sheet

**Every skill and script in this workspace MUST match this sheet.** If the official docs change, update this file first, then reconcile skills.

Source: https://github.com/Kaggle/kaggle-api — verified on CLI 2.0.1.

## Rule 1 — Positional slug

In CLI ≥ 2.0.0, the competition / kernel / dataset / model slug is a **positional argument**, not a `-c` flag.

```
kaggle competitions <subcmd> <slug> [options]     # CORRECT
kaggle competitions <subcmd> -c <slug> [options]  # legacy — do not use in new code
```

## Rule 2 — Competitions subcommands

| Subcommand | Signature |
|---|---|
| list | `kaggle competitions list [--group general\|entered\|inClass] [--category all\|featured\|research\|recruitment\|gettingStarted\|masters\|playground] [--sort-by grouped\|prize\|earliestDeadline\|latestDeadline\|numberOfTeams\|recentlyCreated] [-p PAGE] [-s SEARCH] [-v]` |
| files | `kaggle competitions files <slug> [-v] [-q] [--page-size N] [--page-token T]` |
| download | `kaggle competitions download <slug> [-f FILE] [-p PATH] [-w] [-o] [-q]` — **no `--unzip`** |
| submit (standard) | `kaggle competitions submit <slug> -f FILE -m "MSG"` |
| submit (code) | `kaggle competitions submit <slug> -k OWNER/NOTEBOOK -v VERSION -f OUTPUT_FILENAME -m "MSG"` |
| submissions | `kaggle competitions submissions <slug> [-v] [-q] [--page-size N]` |
| leaderboard | `kaggle competitions leaderboard <slug> [-s] [-d] [-p PATH] [-v] [-q] [--page-size N]` |

## Rule 3 — Datasets subcommands

| Subcommand | Signature |
|---|---|
| list | `kaggle datasets list [-s TERM] [-m] [--user U] [--file-type all\|csv\|sqlite\|json\|bigQuery] [--license all\|cc\|gpl\|odb\|other] [--sort-by hottest\|votes\|updated\|active] [-p PAGE] [-v]` |
| files | `kaggle datasets files <owner>/<slug> [-v] [--page-size N]` |
| download | `kaggle datasets download <owner>/<slug> [-f FILE] [-p PATH] [-w] [--unzip] [-o] [-q]` — **supports `--unzip`** |
| init | `kaggle datasets init -p <dir>` |
| create | `kaggle datasets create -p <dir> [-u] [-q] [-t] [-r skip\|zip\|tar]` |
| version | `kaggle datasets version -p <dir> -m "NOTES" [-q] [-t] [-r skip\|zip\|tar] [-d]` |
| metadata | `kaggle datasets metadata <owner>/<slug> [-p <dir>] [--update]` |
| status | `kaggle datasets status <owner>/<slug>` |
| delete | `kaggle datasets delete <owner>/<slug> [-y]` |

## Rule 4 — Kernels (notebooks / code competitions)

| Subcommand | Signature |
|---|---|
| list | `kaggle kernels list [-m] [-s TERM] [--competition SLUG] [--user U] [--language all\|python\|r] [--sort-by hotness\|dateCreated\|dateRun\|voteCount] [-p PAGE] [--page-size N] [-v]` |
| files | `kaggle kernels files <owner>/<slug> [-v] [--page-size N]` |
| init | `kaggle kernels init -p <dir>` |
| push | `kaggle kernels push -p <dir> [--accelerator ID] [-t SECONDS]` |
| pull | `kaggle kernels pull <owner>/<slug> [-p PATH] [-w] [-m]` |
| output | `kaggle kernels output <owner>/<slug> [-p PATH] [-w] [-o] [-q] [--file-pattern REGEX]` |
| status | `kaggle kernels status <owner>/<slug>` |
| delete | `kaggle kernels delete <owner>/<slug> [-y]` |

### Accelerator IDs (for `kaggle kernels push --accelerator`)
`NvidiaTeslaP100`, `NvidiaTeslaT4`, `NvidiaTeslaT4Highmem`, `NvidiaTeslaA100`, `NvidiaL4`, `NvidiaL4X1`, `NvidiaH100`, `NvidiaRtxPro6000`, `TpuV38`, `Tpu1VmV38`, `TpuV5E8`, `TpuV6E8`. Some are restricted to specific competitions.

## Rule 5 — Models / variations / versions

```
kaggle models init -p <dir>
kaggle models list [--owner O] [--sort-by hotness|downloadCount|voteCount|notebookCount|createTime] [-s TERM] [--page-size N] [-v]
kaggle models get <owner>/<slug> -p <dir>
kaggle models create -p <dir>
kaggle models update -p <dir>
kaggle models delete <owner>/<slug> [-y]

kaggle models variations init -p <dir>
kaggle models variations create -p <dir> [-q] [-r skip|zip|tar]
kaggle models variations files <owner>/<model>/<framework>/<variation> [-v] [--page-size N]
kaggle models variations get <owner>/<model>/<framework>/<variation> -p <dir>
kaggle models variations update -p <dir>
kaggle models variations delete <owner>/<model>/<framework>/<variation> [-y]

kaggle models variations versions create <owner>/<model>/<framework>/<variation> -p <dir> -n "NOTES" [-q] [-r skip|zip|tar]
kaggle models variations versions files <owner>/<model>/<framework>/<variation>/<ver> [-v] [--page-size N]
kaggle models variations versions download <owner>/<model>/<framework>/<variation>/<ver> [-p PATH] [--untar] [--unzip] [-f] [-q]
kaggle models variations versions delete <owner>/<model>/<framework>/<variation>/<ver> [-y]
```

## Rule 6 — Config

```
kaggle config view
kaggle config set -n competition -v <slug>        # pin default competition
kaggle config set -n path -v <dir>                # pin default download path
kaggle config set -n proxy -v <url>
kaggle config unset -n <name>
```

Config lives in `~/.kaggle/kaggle.json` (separate from `~/.kaggle/access_token` which is the API token file).

## Rule 7 — Authentication

CLI resolves auth in this order:
1. `~/.kaggle/access_token` (single-line API token `KGAT_…`, mode 600) ← **recommended**
2. `KAGGLE_API_TOKEN` env var
3. `~/.kaggle/kaggle.json` with `{"username":..., "key":...}` — or `KAGGLE_USERNAME` + `KAGGLE_KEY` env vars

Do not mix methods. Prefer option 1.

## Rule 8 — Things that used to work differently

- `--unzip` exists on `kaggle datasets download` and `kaggle models variations versions download`, but **NOT** on `kaggle competitions download`. Unzip competition data manually after download.
- `-c <slug>` is still accepted as a legacy alias in some subcommands, but the docs only document the positional form. Use positional in all new code.
- Competition slug = URL suffix after `/competitions/` (e.g. `titanic`). Notebook / dataset / model slugs are `owner/slug` pairs. Model variation = `owner/model/framework/variation`. Version = `…/variation/<int>`.

## Rule 9 — Cross-check checklist for any new skill

When writing or editing a skill that invokes `kaggle …`, verify:
- [ ] Slug is positional, not `-c`.
- [ ] `--unzip` only on datasets / model versions, not competitions.
- [ ] Short vs long flags match `--help` for 2.0.1.
- [ ] For code competitions, submit uses `-k OWNER/NOTEBOOK -v VER -f OUTPUT_FILENAME`.
- [ ] Accelerator ID is spelled exactly as listed in Rule 4 (case-sensitive).
