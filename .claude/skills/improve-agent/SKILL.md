---
name: improve-agent
description: Use when asked to improve, iterate, or build a better version of an existing Kaggle simulation/agent competition bot. Triggers on "improve the agent", "make a better version", "vN", "iterate on agent", "what should we try next", or any request to advance beyond the current best submission.
---

# improve-agent

## Overview

Systematic agent improvement loop for simulation competitions. Each iteration is one scientific cycle: diagnose → hypothesize → implement → verify → decide.

**Iron rule:** No new version without a written hypothesis FIRST (`log-experiment`). No submission without local eval FIRST (`run-local-eval`).

## When to Use

- User says "improve", "make it better", "next version", "iterate", "vN", "what should we try"
- Current agent has a known failure mode or rating ceiling
- After reading ladder replays that reveal a pattern
- After a submission regresses (`post-submission-review` pointed at a root cause)

## Step-by-Step Improvement Loop

### 1. Orient — understand current state

```bash
cat competitions/<slug>/submissions/LOG.md
cat competitions/<slug>/experiments/EXPERIMENTS.md
ls competitions/<slug>/agents/
```

Then invoke `recall-learnings` — cite any learning IDs that apply to the proposed direction.

### 2. Diagnose — find the real failure mode

For simulation competitions, do ladder forensics before coding:
- Download or review recent episode replays (via MCP or stored in `replays/`).
- Ask: what did the opponent do that we couldn't answer?

Diagnostic questions to ask about any simulation agent:
- Is the agent losing early (first N turns) or late? → early = setup/defense; late = scaling/endgame
- Is it losing by a small margin or getting crushed? → small = tune; crushed = structural flaw
- Does it lose to specific strategies or broadly? → specific = exploit; broad = fundamentals
- Does it fail on certain seeds / map states? → seed-dependent = brittle heuristic

Read `experiments/strategy_evolution.md` or equivalent if it exists.

**Do NOT skip diagnosis.** Coding before knowing the root cause creates compound regressions.

### 3. Pick ONE hypothesis

One change per version. Compound changes make it impossible to attribute outcomes.

Good hypotheses (direction + magnitude):
- "Increasing fleet floor from 12 to 20 will raise capture success rate and prevent intercepts"
- "Adding reinforcement dispatch before attack selection will reduce first-planet-loss rate"
- "Lead-targeting fast units will add 5-8% win rate on maps with high mobility"

Bad hypotheses:
- "Rewrite the strategy to be smarter" (unmeasurable)
- "Fix a few things and see if it helps" (compound, unattributable)

### 4. Log the experiment FIRST

```
invoke: log-experiment
```

Fill in: hypothesis, setup (seeds, match format), success criteria (numeric), abort condition.

**Do not write any agent code until `log-experiment` is done.**

### 5. Implement in a new versioned folder

```bash
# Name pattern: vN_<short_descriptor>
cp -r competitions/<slug>/agents/v<N-1>_<prior>/ \
      competitions/<slug>/agents/v<N>_<descriptor>/
# Edit agent.py — make only the change in the hypothesis
```

Key invariants for simulation agents:
- The entry-point function (e.g. `def agent(obs):`) must be the **last** top-level `def` in the file — kaggle-environments picks the last one.
- Time budget: stay at or below 80% of the per-turn actTimeout.
- Handle all player-count variants the competition supports (1v1, FFA, etc.).
- Define a fallback move for every code branch — never let the agent return `None`.
- No prints or logging to stdout inside the agent — kaggle-environments may reject it.

### 6. Run local eval — compare against prior versions

```
invoke: run-local-eval
```

Minimum benchmark matrix:
- `vN` vs `v(N-1)`: must win > 55% (if not, hypothesis likely failed)
- `vN` vs `v1_baseline`: sanity floor — should always beat the original
- FFA or multi-player variant: vN should lead or not regress

Record per-seed win/loss, key game metrics (fleet size, turn of first loss, etc.).

### 7. Decide: submit / iterate / abort

| Local result | Decision |
|---|---|
| Wins > 60% vs prior best | Candidate for submission |
| Wins 50–60% vs prior best | Investigate why — iterate first |
| Wins < 50% vs prior best | Abort. Document lesson in EXPERIMENTS.md. Try a different hypothesis. |

**Never submit a version that regresses against the prior best in local eval.**

If submitting → invoke `submit-competition`, then `post-submission-review` after warmup.

### 8. Capture learning

If something surprised you (positive or negative), invoke `capture-learning` immediately.

---

## Versioning Convention

```
agents/
  v1_baseline/          # first working agent
  v2_<change>/          # one change from v1
  v3_<change>/          # one change from v2 (or best-so-far)
```

Version name = `v<N>_<2-3 word descriptor of the ONE change>`.

If a version regresses, keep the folder, mark it in `LOG.md`, and branch next iteration from the last winner.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Coding before diagnosing | Always diagnose → hypothesize → code |
| Submitting without local eval | Local eval catches crashes and regressions |
| Compound changes ("fixing a few things") | One hypothesis per version |
| Entry-point function not last in file | Move it to end; imports and helpers above |
| Missing fallback move | Add default action in every branch |
| Forgetting multi-player/FFA branch | Test with all supported player counts |
| Skipping `log-experiment` | Log it first — even one sentence |
| Stdout/print inside agent | Remove all prints; use a debug flag gated by a variable |
