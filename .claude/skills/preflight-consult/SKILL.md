---
name: preflight-consult
description: Pre-flight sanity check before any major move — new model choice, new feature, new submission, merging a big change. Pulls relevant learnings, runs a self-critique, and asks the user to confirm. Use when about to commit time to a non-trivial direction, OR when the user says "preflight", "sanity check this", "before we go".
---

# Pre-Flight Consultation

Three-minute ritual before committing real time to an approach. Catches mistakes we've already made.

## Steps

1. **Describe the move in one sentence.** E.g. "We're about to train a LightGBM with stratified 5-fold on this competition."
2. **Recall** (invoke `recall-learnings`). Capture 3-5 relevant learnings.
3. **Self-critique.** For each: does our plan honor it? If not, either adjust the plan or write an explicit reason why this case is different.
4. **Checklist specific to the move-type.** Pull from the applicable block below.
5. **Present to the user:**
   ```
   Pre-flight for: <one-sentence plan>
     Priors considered:
       - L-… — <Rule>                → <honored | adjusted | exempt because …>
     Checklist:
       - [x] <item>
       - [ ] <item — action required>
     Proceed? y/n
   ```
6. **Wait for user confirmation** before starting work.

## Checklist blocks by move-type

### Before training a model
- [ ] CV strategy matches the data structure (group-k-fold for user-grouped data, time-split for temporal).
- [ ] Leakage check: any feature constructed using test-set info or future info?
- [ ] Target distribution audited; class imbalance decision explicit.
- [ ] Seed fixed. Reproducibility verified with a 2-run sanity check.
- [ ] Submission columns / dtypes match `sample_submission.csv` exactly.

### Before submitting
- [ ] Local eval / CV score computed, logged in `EXPERIMENTS.md`.
- [ ] Daily submission quota has room.
- [ ] Submission file validated (header, rows, dtypes).
- [ ] Git clean OR user has accepted the dirty-submit risk.
- [ ] Submission message is a meaningful diff, not "test".

### Before a new agent version (simulation)
- [ ] Deterministic under seed.
- [ ] Per-turn time budget respected (< 80% of limit).
- [ ] Fallback move defined for every code branch.
- [ ] Ran ≥ 10 local matches vs prior best; win-rate reported.
- [ ] Entry-point function is the last top-level `def` in the file.

### Before a large refactor
- [ ] Current best submission artifact and code commit are tagged / preserved.
- [ ] A rollback path exists in under 5 minutes.

## The "three-strikes" check

If a learning is `recurring: true` AND relevant to this plan, the default is NO — assume we'll fall into the same pit again unless conditions have materially changed. Ask the user to explicitly acknowledge: "we have changed X since the last time this bit us."
