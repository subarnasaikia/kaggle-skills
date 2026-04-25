---
name: log-experiment
description: Record a scientific-method entry for an experiment — hypothesis, setup, outcome, lesson. Use before running any non-trivial experiment (new feature, new model, new CV strategy, new agent tactic) so the hypothesis is written down BEFORE the result. Also use when the user says "log experiment", "track this test", or "record the hypothesis".
---

# Experiment Ledger

Keeps you honest: you state what you expect before you see the result. Over time this is where you find your calibration blind spots.

## File

`competitions/<slug>/experiments/EXPERIMENTS.md`. Append-only. Newest last.

Create the file with a header if absent:
```markdown
# Experiments — <slug>

Format per entry:
- **ID / date / branch-or-commit**
- **Hypothesis** — predict direction + magnitude
- **Setup** — what's different from baseline
- **Priors** — learning IDs cited (from recall-learnings)
- **Outcome** — CV metric, LB delta if submitted
- **Lesson** — what the result updated in your mental model

---
```

## Steps (before running)

1. **Invent the ID:** `E-YYYY-MM-DD-NNN` (sequence per-day, per-competition).
2. **Write the entry stub** (all fields except Outcome and Lesson):
   ```markdown
   ## E-2026-04-18-001  (2026-04-18, branch: agent-v3)
   **Hypothesis** — Adding 3-turn lookahead in the greedy scorer will lift win-rate vs baseline from ~60% to 70-75%.
   **Setup** — `agents/v3_lookahead/agent.py`; identical opponent; N=50 matches; seed pool {0..49}.
   **Priors** — (cite any from recall-learnings)
   **Outcome** — (pending)
   **Lesson** — (pending)
   ```
3. **Recall.** Run the `recall-learnings` skill with keywords from Setup; cite anything applicable in the `**Priors**` line.

## Steps (after running)

4. **Fill Outcome** with concrete numbers. Include direction (improved / regressed / flat) and magnitude.
5. **Fill Lesson** in one sentence — the delta between your hypothesis and the outcome:
   - Hypothesis matched → lesson is about what confirmed it (strengthen the pattern).
   - Hypothesis missed → lesson is about which assumption broke (weaken or invert the pattern).
6. **Decide capture.** If the Lesson is durable beyond this experiment, invoke `capture-learning` to promote it to `.learnings/`.

## Discipline

- **Hypothesis must predict direction AND magnitude.** "It will help" is not a hypothesis.
- **Setup must be reproducible.** Seed, sample size, opponent/baseline, code branch.
- **Lesson must be one sentence.** If it needs more, it belongs as a capture.

## The calibration loop

After every 10 experiments, run a meta-review: how often did your hypotheses match in direction? In magnitude? Systematic overconfidence → predict smaller effects. Systematic underconfidence → try bolder changes.
