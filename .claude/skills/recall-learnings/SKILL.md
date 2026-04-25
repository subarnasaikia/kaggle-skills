---
name: recall-learnings
description: Surface prior learnings relevant to the current task. Use before starting any non-trivial work — new experiment, new feature, new submission strategy, debugging a pattern — to check if we've been here before. Also use when the user says "what have we learned about X", "any past notes on Y", "recall", or "check learnings".
---

# Recalling Prior Learnings

Surfaces the most relevant learnings from `.learnings/` for the task at hand. This is the compound-interest mechanism — every session should call it before committing to an approach.

## When to invoke proactively

Before:
- Picking a modeling approach ("LightGBM vs CatBoost for tabular").
- Designing a CV split strategy.
- Writing submission glue code for a new competition.
- Starting an agent's main decision loop.
- Deciding a hyperparameter range.
- Writing code that touches the Kaggle CLI / MCP.

Basically: **any time you would otherwise guess**, recall first.

## Steps

1. **Build a query.** Extract 3-6 keywords from the task at hand. Examples:
   - "class imbalance" + "lightgbm" + "tabular"
   - "agent timeout" + "simulation" + "move budget"
   - "submission format" + "csv" + "leaderboard regression"
2. **Scope filter.** If inside `competitions/<slug>/`, include both `scope: global` and `scope: <slug>`. Otherwise global only.
3. **Search:**
   ```bash
   # tag-first (precise)
   grep -l -E "tags:.*\b(<tag1>|<tag2>)\b" .learnings/L-*.md
   # keyword fallback
   grep -l -i -E "<keyword1>|<keyword2>" .learnings/L-*.md
   ```
4. **Rank** by: `recurring=true` first, then `cost: high`, then `severity: scar`, then recency. Cap at 5.
5. **Read the top matches.** Extract the **Rule** lines only.
6. **Present** to the user as a compact numbered list: `[ID] Rule — (scope, cost)`.
7. **Apply.** When proceeding, explicitly cite the learnings you are honoring: "Applying L-… by using stratified k-fold instead of random split."

## Example output

```
Relevant prior learnings:
  1. L-2026-03-02-001 — Cast submission ID columns with .astype(int) before writing (global, high-cost)
  2. L-2026-03-15-003 — Stratified-by-target beats random split on tabular competitions (global, medium)
  3. L-2026-03-20-002 — Leaderboard-driven overfit: trust CV when delta > 0.01 (global, high-cost)
Applying: casting IDs, stratified split.
```

## Anti-patterns

- Don't dump every matching learning verbatim — pick the top 3-5 and show only their **Rule** lines.
- Don't invent learnings that "feel right." If nothing matches, say so; that's honest and opens a slot for a new capture later.
- Don't recall, list, and then ignore — citing a learning in the plan is what enforces discipline.
