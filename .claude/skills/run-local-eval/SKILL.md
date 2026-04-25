---
name: run-local-eval
description: Run the local kaggle-environments evaluation harness for a simulation/agent competition. Use when the user says "local eval", "test agent", "run simulation", "self-play", or before submitting an agent.
---

# Running Local Evaluation for Agent Competitions

## When to use

Before any agent submission. Catches timeouts, invalid moves, crashes, and regressions that would waste a daily submission slot.

## Steps

1. **Locate competition folder.** Must have `agents/` directory and be a `kaggle-environments`-compatible competition.
2. **Identify agents under test.** Default: latest versioned agent in `agents/`, pitted against `agents/baseline/agent.py` if present, else self-play.
3. **Install `kaggle-environments`** if missing in the competition's venv:
   ```bash
   uv pip install kaggle-environments
   ```
4. **Run match:**
   ```python
   from kaggle_environments import make
   env = make('<slug>', debug=True)
   result = env.run(['agents/<a>/agent.py', 'agents/<b>/agent.py'])
   ```
5. **Capture metrics:**
   - Winner (2-player) or ranking (multi-player)
   - Turn count
   - Max per-turn time (ms) for each agent
   - Any error messages in the replay
6. **Validate against competition constraints** (read from `competitions/<slug>/CLAUDE.md`):
   - Per-turn time budget — flag any turn > 80% of budget.
   - Action space — log invalid actions.
   - Agent stdout/stderr spam — flag anything printed (kaggle-environments may capture or discard it).
7. **Save replay** to `competitions/<slug>/replays/<timestamp>_<a>_vs_<b>.json` for post-mortem.
8. **Run N matches** for statistical signal (default N=10 unless user overrides):
   - Report win rate, mean turn count, max turn time distribution.
9. **Report** a compact summary to user.

## Output format

```
Local Eval: <a> vs <b>
  Matches: 10
  Wins: 7 / 3
  Avg turns: 124
  Max move time: 340ms (budget 500ms) — OK
  Invalid moves: 0
  Errors: 0
```

## Do NOT

- Do not skip local eval before submission.
- Do not claim "passed" based on a single match — noise dominates in few-match samples.
- Do not run matches without capturing replays; debugging later needs them.
- Do not run eval in the workspace root; always activate the competition's `.venv` first.
