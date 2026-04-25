# MCP vs CLI vs kagglehub — Decision Guide

Three tools, overlapping capabilities, different sweet spots. Choosing the wrong one burns tokens or masks errors. This file dictates which tool to use when.

## TL;DR decision table

| Task | Use | Why |
|---|---|---|
| Download competition data (any size) | **CLI** | Bytes bypass context entirely |
| Upload a submission file | **CLI** | Same — avoid routing file bytes through MCP |
| Submit a code-competition notebook run | **MCP** (`create_code_competition_submission`) | One structured call vs. multi-step CLI chain |
| "What's the scoring metric for X?" | **MCP** | Targeted single-field fetch; small response |
| "List top 5 competitions" | **MCP** | Structured, small, easy to summarize |
| List 50+ competitions/datasets | **CLI** with `--page-size` + `-q` | MCP JSON blows up context; CLI output is tight |
| Fetch competition leaderboard for ranking check | **CLI** `leaderboard <slug> --show --page-size 30` | Human-formatted, small |
| Download full leaderboard for offline analysis | **CLI** `leaderboard <slug> -d -p .` | File, not context |
| Polling kernel/dataset status in a loop | **CLI** | Scriptable; MCP polling spams context |
| Loading a dataset inside Python code | **kagglehub** | Built for programmatic use; auto-caches |
| Loading model weights inside Python | **kagglehub** | Same |
| Inside a Kaggle-hosted notebook | **kagglehub** | Pre-installed, offline-friendly |
| Automation / cron / scripts | **CLI** | No MCP runtime dependency |
| Discovery / brainstorming / "what exists" | **MCP** | Natural-language querying, small targeted payloads |

## Priority rule of thumb

```
data bytes or bulk output  → CLI
single structured field    → MCP
python runtime imports     → kagglehub
```

## Decision flowchart

```
Is the operation a transfer of files (download, upload)?
  yes → CLI
  no  → continue

Is it inside Python code that needs paths to data/weights?
  yes → kagglehub
  no  → continue

Is the result a list of 20+ items?
  yes → CLI with --page-size and -q; pipe to file if large
  no  → continue

Is the step part of a loop / script / unattended automation?
  yes → CLI
  no  → continue

Is it a small structured lookup ("get the metric", "what files are in X")?
  yes → MCP
  no  → CLI (default)
```

## Why the split (the real reasons)

### Token economics

- **MCP responses are JSON.** A list of 100 competitions ≈ 15–30 KB of JSON → ~5–10k tokens dropped into context every call. Repeated calls compound.
- **CLI responses are text tables.** Same 100 rows ≈ 4–8 KB, and with `-q --page-size 20` you cap it at a few hundred tokens.
- **File output.** CLI can redirect to disk (`> leaderboard.csv`); nothing enters context. MCP can't.
- **Pipes and filtering.** CLI can `grep`, `head`, `jq`. You pay only for the filtered subset.

Rule: **if the answer is a single fact, MCP is cheaper; if the answer is a list, CLI is cheaper.**

### Coverage

Kaggle's official MCP at `https://www.kaggle.com/mcp` doesn't cover everything the CLI does.

- **MCP covers:** browse competitions/datasets/models/notebooks · standard submission upload · code-competition submission · leaderboard · forum topics.
- **CLI covers everything:** all of the above plus `config set/unset`, `kernels push` with accelerators, `datasets create/version`, `models create/update`, variation management.

When in doubt, use CLI — it's the complete surface.

## Default conventions

1. **Always prefer CLI for any side-effectful operation** (download, submit, create, delete). Easier to audit in logs.
2. **Use MCP for "glance" queries** during planning — single facts, small lists.
3. **Never route raw competition data or leaderboard CSVs through MCP.** Always file-redirect via CLI.
4. **In Python code**, use `kagglehub` for anything that loads data at runtime. Do not shell out to `kaggle` from Python.

---

# kagglehub — when you need it

| Thing | Purpose | Consumer |
|---|---|---|
| `kaggle` CLI binary | Terminal operations | You in a shell |
| `kaggle` Python package (legacy) | Scripted API calls | Old code |
| `kagglehub` Python package | Runtime data/model loading with auto-cache | Notebooks, agents, scripts |

## Install per competition

```bash
cd competitions/<slug>
uv venv --python 3.11
uv pip install kagglehub
```

Auth is automatic — reads the same `~/.kaggle/access_token`.

## Minimal usage

```python
import kagglehub

path = kagglehub.dataset_download("owner/slug")          # auto-cached
path = kagglehub.dataset_download("owner/slug", version=2)
weights = kagglehub.model_download("owner/model/framework/variation")
path = kagglehub.competition_download("competition-slug") # if supported
```

## Do you need it?

- **CLI-only workflows** (browse, download once, submit): no.
- **Simulation-agent competitions** (pure Python agent receiving game state): no.
- **Tabular / CV / NLP** training code that loads data programmatically: **yes** — simplifies paths, caches across reruns.
- **Code competitions on Kaggle notebooks**: **yes** — pre-installed on Kaggle, so same code works locally and on the platform.
- **Pulling pretrained models from Kaggle Models hub**: **yes** — cleanest way.

## Operational recipes

### Start a new competition — which tools

1. **MCP** to browse the competition overview, metric, rules (one call, small response).
2. **CLI** `kaggle competitions files <slug>` to see file list.
3. **CLI** `kaggle competitions download <slug> -p data/` for the actual bytes.
4. **kagglehub** inside Python training code to load data reproducibly.
5. **CLI** for submissions.
6. **MCP** for ad-hoc "what's my current rank" queries.

### Iterate on an agent — which tools

- Editor + local Python: no Kaggle API at all.
- Local eval: `kaggle-environments` — zero Kaggle API.
- Submit: CLI.
- Post-submit ranking check: MCP (one tiny call) or CLI `--page-size 10`.
