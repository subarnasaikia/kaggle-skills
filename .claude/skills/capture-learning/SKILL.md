---
name: capture-learning
description: Capture a single learning to .learnings/ when something surprising, painful, or validation-worthy happens during Kaggle work. Use proactively whenever an experiment fails for a non-obvious reason, a submission regresses, you hit a tool/API quirk, or a non-obvious approach is confirmed to work. Also use when the user says "remember this", "save this learning", "log this", or describes a mistake they don't want repeated.
---

# Capturing a Learning

Claude writes a single self-contained learning file to `.learnings/`. Each file is a durable memory that future sessions will read via the `SessionStart` hook and the `recall-learnings` skill.

## When to invoke proactively

Any of:
- Submission score regressed and we now know why.
- An experiment failed for a non-obvious reason (class imbalance, leak, time budget, CV/LB mismatch).
- A Kaggle CLI / MCP / env quirk bit us (auth, rate limit, flag syntax, format gotcha).
- A non-obvious approach was confirmed to help (e.g. "group-k-fold by user_id beat random split by 0.02 AUC").
- The user explicitly asks to remember something.

## When NOT to invoke

- When the fact is already in the codebase or git history. Those are not learnings — read them directly.
- When the fact is generic textbook ML. Reserve learnings for things specific to our work.
- When it's a fleeting task detail — use a todo, not a learning.

## Steps

1. **Determine scope:**
   - If it generalizes across competitions → `scope: global`.
   - If it only applies to the current competition → `scope: <slug>` (infer from cwd).
2. **Pick tags** from the stable families (see `.learnings/README.md`). Add one to three tags. Prefer reuse over invention.
3. **Estimate severity and cost:**
   - `scar` + `cost: high` when it burned a submission slot or > 8h.
   - `scar` + `cost: medium` when it cost 1–8h.
   - `pattern` when it's a validated-good approach.
   - `note` when it's a mild gotcha.
4. **Check for near-duplicates** — run `grep -l "<key phrase>" .learnings/L-*.md`. If found, decide: update the existing file, mark the older one `recurring: true`, or supersede it with a new file that references it.
5. **Generate an ID:** `L-$(date +%Y-%m-%d)-NNN` where `NNN` is the next free 3-digit sequence for that date. Use `ls .learnings/L-$(date +%Y-%m-%d)-*.md 2>/dev/null | wc -l` to pick NNN.
6. **Write the file** using the template in `.learnings/README.md`. Keep the body under 20 lines.
7. **Confirm to the user** in one short sentence: "Captured L-… on <topic>."

## What makes a good learning

- **Specific scar.** "Submitted a CSV where ID column was float instead of int; Kaggle rejected the format." Not "watch out for types."
- **Actionable rule.** "Cast submission ID column with `.astype(int)` before writing." Not "be careful."
- **How to apply.** One or two lines on when and where the rule kicks in.
- **Link related learnings** if this is a sibling or corrects an earlier one.

## Creative directive

Write as if leaving a note for the next Claude session that has never seen this project. They need to act correctly on incomplete information. A good learning is one where reading only the **Rule** line is enough to avoid the mistake.
