---
name: leaderboard-check
description: Pull the current Kaggle leaderboard for a competition and compare against the user's best score. Use when the user says "leaderboard", "how are we doing", "score vs top", or "where do we rank".
---

# Checking the Competition Leaderboard

## Steps

1. **Resolve slug** from cwd (`competitions/<slug>/`) or user input.
2. **Pull leaderboard** (slug is positional in CLI ≥ 2.0.0):
   ```bash
   kaggle competitions leaderboard <slug> --show --page-size 30
   ```
   Download full board to CSV if needed:
   ```bash
   kaggle competitions leaderboard <slug> --download --path .
   ```
   Or via MCP if a leaderboard tool is exposed (`mcp__kaggle__get_competition_leaderboard`).
3. **Pull user's submissions:**
   ```bash
   kaggle competitions submissions <slug> --page-size 10
   ```
4. **Report:**
   - Current rank (if user is on LB)
   - User's best public score
   - Top score
   - Gap to top
   - Gap to top-10 cutoff
   - Gap to bronze / silver / gold medal cutoffs (if known from competition page)
5. **Trend:** compare to last check — if `competitions/<slug>/submissions/LOG.md` has prior entries, show delta vs. previous best.

## Do NOT

- Do not spam the leaderboard endpoint — cache results for 5 minutes if checking repeatedly.
- Do not interpret public-leaderboard position as final; private LB may differ significantly.
- Do not suggest submitting solely to improve rank — submit only when you have a real improvement.
