# <slug> — Simulation / Agent Competition Rules

## Scoring
- Metric: <!-- win-rate | rating (TrueSkill / Elo) | score -->
- Direction: higher-better
- Local proxy: `kaggle-environments` win-rate over N=50 self-play matches

## Submission
- Format: `agent.py` (or `main.py`) packed in `<slug>.tar.gz`
- Daily limit: <!-- N -->
- Local validator:
  ```python
  from kaggle_environments import make
  env = make("<slug>", debug=True)
  env.run(["agents/<version>/agent.py", "agents/baseline/agent.py"])
  ```

## Time budget
- Per-turn limit: <!-- e.g. 1000 ms -->
- Target max: <!-- 800 ms (80% of limit) -->
- Measure with: `import time; t=time.time(); ...; print(time.time()-t)`

## Agent invariants
- Entry-point function (`def agent(obs):`) must be the **last** top-level `def` in the file.
- Return a valid action for every possible observation — never return `None`.
- No `print()` inside the agent — kaggle-environments may reject stdout.
- Deterministic given a seed — log the seed for every eval run.

## Player count variants
- <!-- e.g. "supports 1v1 and 4-player FFA — test both" -->
- Handle via: `if len(obs["players"]) == 2: ...  else: ...`

## Versioning convention
```
agents/
  v1_baseline/      # first working agent
  v2_<change>/      # one hypothesis per version
```

## Known quirks
- <!-- e.g. "observation key 'step' only present for player 0" -->
- <!-- e.g. "comet IDs live in obs['comet_planet_ids'], not obs['comets'][i][0]" -->

## References
- Overview : https://www.kaggle.com/competitions/<slug>/overview
- Rules    : https://www.kaggle.com/competitions/<slug>/rules
