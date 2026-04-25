---
name: post-submission-review
description: After any kaggle submission, diff against the prior best submission, fetch the new public score, write the outcome to the competition's submissions/LOG.md, and capture a learning if the delta is notable. Triggered automatically by a PostToolUse hook on `kaggle competitions submit`. Also use when the user says "review that submission" or "what did that submission do".
---

# Post-Submission Review

The discipline that turns each submission into a data point with a lesson attached.

## Steps

1. **Identify the submission just made.** Read the last line of `competitions/<slug>/submissions/LOG.md` if present, otherwise list recent submissions:
   ```bash
   kaggle competitions submissions <slug> --page-size 3
   ```
2. **Poll for score.** Up to ~3 minutes, every 15s:
   ```bash
   kaggle competitions submissions <slug> --page-size 1
   ```
   Stop once `status` is `complete` or `error`.
3. **Compute delta** against prior best. Prior best = highest `publicScore` in submission history. Respect the scoring direction — higher-better vs lower-better; read from `competitions/<slug>/CLAUDE.md`.
4. **Append / update the `LOG.md` row** with final public score and a one-line notes field.
5. **Classify the outcome:**
   - Improved > meaningful threshold (competition-specific; default 0.001 absolute) → `pattern` learning candidate.
   - Regressed > threshold → `scar` learning candidate.
   - Flat ±threshold → no learning; log as `noise-equivalent` in notes.
   - Errored (invalid format, timeout) → `scar`, always.
6. **Collect the cause.** Based on session context: **what changed between this submission and the prior best?**
   - Use git: `git log --oneline <prior-commit>..HEAD -- competitions/<slug>`.
   - If no git history, ask the user in one line: "What changed since last submission?"
7. **If a learning candidate**, invoke `capture-learning` with:
   - `scope: <slug>` unless the change clearly generalizes globally.
   - Scar or pattern per step 5.
   - Tags: `submission`, `<metric-name>`, and any technique tag (e.g. `feature-eng`, `hyperparam`, `ensemble`).
8. **Summarize** to the user:
   ```
   Submission: <file> — <score> (Δ +0.0042 vs best)
   Cause: <what changed>
   Captured: L-… (pattern)
   ```

## Do NOT

- Don't auto-capture learnings on noise-level deltas — save the slot for real signal.
- Don't trust a single submission's public score on a small leaderboard — note it but flag `cv-lb-mismatch` as a risk.
- Don't re-submit the same artifact to "check noise." Submission quota is precious.

## Lineage

Treat each submission as a node in a tree whose parent is the prior best. The delta is the edge label. Over time, this tree shows which branches paid off. When you capture a learning, reference the submission IDs ("L-… explains the gain from sub-023 → sub-024").
