---
name: debug-agent
description: Step through a simulation agent replay to find where and why it failed — timeout, invalid move, crash, or strategic collapse. Use when the user says "debug the agent", "why did it lose", "find the failing turn", "analyze the replay", or after a regression in local eval.
---

# Debug Agent — Replay Forensics

Turns a raw replay JSON into a structured diagnosis: which turn failed, what state the agent saw, what it returned, and why.

## When to use

- Local eval showed a loss, crash, or invalid move.
- A submission scored worse than expected; you have a replay to examine.
- An agent works in 1v1 but fails in FFA (or vice versa).
- A specific seed consistently loses; others are fine.

## Steps

### 1. Locate the replay

```bash
ls competitions/<slug>/replays/
# pick the most recent or the one from the failing seed
```

Replays are JSON produced by kaggle-environments. Structure:
```json
{
  "steps": [ [ { "observation": {...}, "action": ..., "status": "ACTIVE|DONE|ERROR|INVALID" } ] ]
}
```

### 2. Parse and summarize the replay

Run this snippet (adapt `replay_path` and player index):

```python
import json
from pathlib import Path

replay = json.loads(Path("competitions/<slug>/replays/<file>.json").read_text())
steps  = replay["steps"]
n_players = len(steps[0])

print(f"Total turns: {len(steps)}  |  Players: {n_players}")
for t, step in enumerate(steps):
    for p, agent_step in enumerate(step):
        status = agent_step.get("status", "?")
        action = agent_step.get("action")
        if status in ("ERROR", "INVALID", "DONE"):
            print(f"  turn {t:3d}  player {p}  status={status}  action={action!r}")
```

### 3. Diagnose by status code

| Status | Meaning | First thing to check |
|---|---|---|
| `ERROR` | Agent raised an exception | Print `agent_step["info"]` for traceback; reproduce locally with `debug=True` |
| `INVALID` | Agent returned an illegal action | Print the observation at that turn; check action space bounds |
| `TIMEOUT` | Agent exceeded per-turn time budget | Instrument the slow function; check O(N²) loops or unnecessary recomputation |
| `DONE` (early) | Agent lost — game ended before max turns | Check score/fleet at losing turn; is it a bleed or a sudden collapse? |

### 4. Inspect the failing turn in detail

```python
t_fail = <turn number from step 3>
p_fail = <player index>

step   = steps[t_fail][p_fail]
obs    = step["observation"]
action = step["action"]
status = step["status"]
info   = step.get("info", {})

print(f"Turn {t_fail} | Player {p_fail} | Status: {status}")
print(f"Action returned: {action!r}")
print(f"Info / error:    {info}")
print(f"Observation keys: {list(obs.keys())}")
# Drill into the specific obs fields your agent uses
```

### 5. Reproduce locally with debug=True

```python
from kaggle_environments import make

env = make("<slug>", debug=True)
env.run(["competitions/<slug>/agents/<version>/agent.py",
         "competitions/<slug>/agents/baseline/agent.py"])

# Print per-step debug output
for i, step in enumerate(env.steps):
    print(f"turn {i}", step)
```

### 6. Report findings

Write a structured diagnosis:

```
Debug report: <agent-version> vs <opponent> (seed <N>)
  Failure turn : <T>
  Player       : <P>
  Status       : ERROR | INVALID | TIMEOUT | early-DONE
  Root cause   : <one sentence — what the agent did or failed to do>
  Evidence     : <observation field or exception line>
  Fix candidate: <what to change in the agent>
```

Then invoke `log-experiment` to record the hypothesis for the fix, and `improve-agent` to implement it.

## Do NOT

- Don't guess the root cause without reading the replay. "It probably timed out" is not a diagnosis.
- Don't fix and re-run without writing down what you expect the fix to achieve (`log-experiment` first).
- Don't discard replays after debugging — keep them in `replays/` as regression anchors.
