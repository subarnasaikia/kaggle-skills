---
name: retrospect-session
description: Session-end retrospective that extracts 0-3 durable learnings from the conversation, updates the LEARNINGS.md digest, and flags recurring scars. Use when the user says "retro", "retrospect", "wrap up", "end of session", "what did we learn today", or when a long working session is winding down. The Stop hook also nudges this skill.
---

# Session Retrospective

Reviews what happened during the session, extracts durable learnings, and keeps `LEARNINGS.md` lean.

## Steps

1. **Scan the session.** Identify moments where:
   - An approach was tried and failed.
   - An approach was tried and worked against expectation.
   - A tool / API / environment quirk was discovered.
   - A user correction changed direction.
   - A hypothesis was confirmed or rejected by data.
2. **Filter to durable material.** Drop anything already recorded in code, git history, a commit message, or an existing learning. Target: 0 to 3 new learnings per session; zero is a valid answer.
3. **For each surviving item**, invoke the `capture-learning` skill (one per item).
4. **Update `LEARNINGS.md` digest:**
   - Pull the 10 most recent `scar` + `pattern` learnings across all competitions.
   - Render them as `- L-… — <Rule> (scope, cost)` under the `<!-- BEGIN:RECENT -->` block.
   - For any learning with `recurring: true` OR `cost: high`, also ensure it appears in the `<!-- BEGIN:PINNED -->` block (dedupe by ID).
   - Keep pinned ≤ 15 entries. Evict the oldest non-recurring high-cost ones when over budget.
   - Alternatively, run `scripts/kln digest` to rebuild both blocks automatically.
5. **Detect recurrence.** For any newly-captured scar, run `grep -l -i "<same root cause>" .learnings/L-*.md`. If the same root cause has appeared ≥ 2 times, mark `recurring: true` in the new file AND the older file(s), and add to pinned.
6. **Prune stale.** If any learning references code paths that no longer exist, a Kaggle API behavior that has changed, or a library version no longer in use, move it to `.learnings/archive/` with a one-line reason in its frontmatter (`archived_reason: ...`, `archived_date: ...`). Never silently delete.
7. **Write a 3-line summary** to the user:
   ```
   Retro:
     Captured: L-…, L-…
     Pinned: L-… now recurring
     Archived: L-… (API deprecated)
   ```

## When there's nothing to capture

Say so in one line: "Retro: no durable learnings this session." Do not invent. Do not pad. Zero learnings is compatible with a productive session.

## Creative directive — the scar compiler

Think of yourself as editing a project post-mortem wiki. Every line should be readable by a stranger. Rules first, war stories second. If a learning file reads like a diary entry, rewrite the Rule line so the future reader doesn't have to unpack the story.
