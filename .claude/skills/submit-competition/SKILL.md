---
name: submit-competition
description: Submit a file to a Kaggle competition with pre-flight validation and post-submit logging. Use when the user says "submit", "send submission", "push to kaggle", or "make a submission".
---

# Submitting to a Kaggle Competition

## Hard rules

- **Never submit without explicit user confirmation.** Submissions burn daily quota.
- **Never submit uncommitted code** unless user accepts the risk. Offer to commit first.
- **Always run the local evaluator first** if one exists for the competition.

## Required steps

1. **Locate competition folder.** Expect cwd to be `competitions/<slug>/` or user specifies slug.
2. **Identify submission artifact.** Must be one of:
   - `submission.csv` / `submission.zip` for tabular
   - `agent.py` / `main.py` for simulation
   - Notebook slug for notebook-based competitions
3. **Pre-flight checks:**
   - File exists and non-empty.
   - For CSVs: header matches `sample_submission.csv`, row count sane.
   - For agents: imports resolve (`python3 -c "import agent"`).
   - Git status clean (warn if dirty).
4. **Check daily quota:** `kaggle competitions submissions <slug>` and count today's submissions. Compare against known limit from `CLAUDE.md`.
5. **Confirm with user:**
   - Show file path, size, detected format.
   - Show submission message (ask user for one; default: first line of latest git commit).
   - Show today's quota usage (N of M submitted).
   - Require explicit "yes" before running submit.
6. **Submit.** Preferred: use the shared Python helper which handles archival + LOG in one call:
   ```bash
   # from workspace root
   python3 shared/utils/submit.py <slug> <file> "<message>"
   ```
   Or call the CLI directly (two forms, slug is positional in CLI ≥ 2.0.0):
   - **Standard (CSV/file submission):**
     ```bash
     kaggle competitions submit <slug> -f <file> -m "<message>"
     ```
   - **Code competition (notebook-based):**
     ```bash
     kaggle competitions submit <slug> -k <username>/<notebook-slug> -v <version> -f <output-filename> -m "<message>"
     ```
     Flags: `-k` kernel ref · `-v` kernel version (int) · `-f` name of the file the notebook produces.
   - **MCP alternative** when natural-language flow preferred: `mcp_kaggle_start_competition_submission_upload` → `kaggle_mcp_submit_to_competition`; for notebook-based: `create_code_competition_submission`.
7. **Poll status** (scoring takes seconds to minutes):
   ```bash
   kaggle competitions submissions <slug> --page-size 5
   ```
8. **Log to `submissions/LOG.md`** — append row with: date (UTC), file, message, public score, notes.
9. **Copy the submission file** into `submissions/YYYY-MM-DD_HHMM_<short-msg>.<ext>` for archival.
10. **Report** public score and delta vs. previous best.

## Notebook-based (code) competitions — end-to-end CLI flow

1. **Pull local copy of notebook:**
   ```bash
   kaggle kernels pull <username>/<notebook-slug> -m -p notebooks/<slug>
   ```
2. **Edit** the `.ipynb` (or `.py`) and `kernel-metadata.json`. Ensure `competition_sources` references the competition.
3. **Push** to Kaggle and trigger a run:
   ```bash
   kaggle kernels push -p notebooks/<slug>
   ```
   Optional: `--accelerator NvidiaTeslaT4` and `--timeout <sec>`.
4. **Wait for run to finish:**
   ```bash
   kaggle kernels status <username>/<notebook-slug>
   ```
   Block until `complete`. Abort on `error`.
5. **Inspect outputs:**
   ```bash
   kaggle kernels output <username>/<notebook-slug> -p notebooks/<slug>/out/ -o
   ```
6. **Submit the notebook run:**
   ```bash
   kaggle competitions submit <slug> -k <username>/<notebook-slug> -v <version> -f submission.csv -m "<message>"
   ```

## Failure modes

- **403 Forbidden** → user hasn't accepted competition rules. Open competition page.
- **Invalid submission format** → compare against `sample_submission.csv`; usually a column order or dtype mismatch.
- **Quota exceeded** → stop; tell user the wait until reset (midnight UTC).
- **Agent timeout** → local eval should have caught this. Tighten time budget before retry.

## Post-submit

- If score improved, suggest: "commit model artifacts? tag as best-so-far?"
- If score regressed, suggest: "diff against last best submission — what changed?"
- Never auto-tag, auto-commit, or auto-push. User drives.
