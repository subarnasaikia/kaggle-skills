# Global Learnings Digest

The curated top shelf. Pinned lessons that apply across all competitions, sorted by cost and recency. Automatically loaded at every session start by the `SessionStart` hook.

**Do not bloat this file.** It should stay under ~60 lines. Anything longer lives in `.learnings/L-*.md` and is surfaced on-demand by the `recall-learnings` skill.

<!-- BEGIN:PINNED -->
## Pinned — recurring or high-cost scars

_(no pinned learnings yet)_
<!-- END:PINNED -->

<!-- BEGIN:RECENT -->
## Recent — last 10 scars / patterns across all competitions

_(none yet)_
<!-- END:RECENT -->

## How to read this file

- Pinned block is the cheat sheet — skim it before starting any new task.
- Recent block is the "what's on my mind" rolling window.
- For the full corpus, run `scripts/kln list` or ask Claude to "recall learnings about <topic>".

## How to write to this file

You don't — Claude does, via `retrospect-session`. To add a learning manually, use `scripts/kln add` and it will land in both `.learnings/` and, if high-cost or recurring, the pinned block here.
