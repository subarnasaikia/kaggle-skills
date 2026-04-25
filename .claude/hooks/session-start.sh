#!/usr/bin/env bash
# SessionStart hook — injects curated learnings into the session context.
# Reads stdin JSON to get cwd; surfaces global + competition-scoped learnings.
set -euo pipefail

# Parse hook input (cwd, source, session_id)
CWD="$(cat - 2>/dev/null | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || true)"
[ -z "$CWD" ] && CWD="$(pwd)"

# Detect workspace root: walk up from cwd until we find CLAUDE.md + .claude/
ROOT=""
dir="$CWD"
while [ "$dir" != "/" ]; do
  if [ -f "$dir/CLAUDE.md" ] && [ -d "$dir/.claude" ] && [ -d "$dir/.learnings" ]; then
    ROOT="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done

# Abort quietly if we're not inside a kaggle-skills workspace
[ -z "$ROOT" ] && exit 0

# Detect which competition we're in, if any
SLUG=""
case "$CWD" in
  "$ROOT"/competitions/*)
    SLUG="${CWD#$ROOT/competitions/}"
    SLUG="${SLUG%%/*}"
    ;;
esac

echo "### Kaggle workspace context loaded"
echo ""

# 1) Always emit the global digest (first 60 lines)
if [ -s "$ROOT/LEARNINGS.md" ]; then
  echo "#### Global Learnings Digest (top of $ROOT/LEARNINGS.md)"
  sed -n '1,60p' "$ROOT/LEARNINGS.md"
  echo ""
fi

# 2) If inside a competition, emit its LEARNINGS + last 5 submission rows
if [ -n "$SLUG" ] && [ -d "$ROOT/competitions/$SLUG" ]; then
  echo "#### Competition: $SLUG"
  if [ -s "$ROOT/competitions/$SLUG/LEARNINGS.md" ]; then
    echo "Competition-scoped learnings:"
    sed -n '1,40p' "$ROOT/competitions/$SLUG/LEARNINGS.md"
    echo ""
  fi
  if [ -s "$ROOT/competitions/$SLUG/submissions/LOG.md" ]; then
    echo "Recent submissions (last 5):"
    tail -n 6 "$ROOT/competitions/$SLUG/submissions/LOG.md"
    echo ""
  fi
fi

# 3) Emit a reminder pointer
echo "#### Reminder"
echo "Before any non-trivial move, invoke the \`recall-learnings\` skill. Capture new scars with \`capture-learning\`. Run \`retrospect-session\` at session end."
