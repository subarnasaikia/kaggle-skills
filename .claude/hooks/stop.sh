#!/usr/bin/env bash
# Stop hook — runs every time Claude finishes a response.
# Silent unless the session looks "substantive" (new learnings or recent submissions),
# then emits one nudge line that Claude sees on the next turn.
set -euo pipefail

INPUT="$(cat - 2>/dev/null || true)"
STOP_HOOK_ACTIVE="$(printf '%s' "$INPUT" | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('stop_hook_active',False))" 2>/dev/null || echo False)"
CWD="$(printf '%s' "$INPUT" | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")"

# Never recurse
[ "$STOP_HOOK_ACTIVE" = "True" ] && exit 0

# Detect workspace root
ROOT=""
dir="${CWD:-$(pwd)}"
while [ "$dir" != "/" ]; do
  if [ -f "$dir/CLAUDE.md" ] && [ -d "$dir/.claude" ] && [ -d "$dir/.learnings" ]; then
    ROOT="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done

[ -z "$ROOT" ] && exit 0

# Substantive-session heuristic: new learning in last 30 min OR recent submission
RECENT_LEARNING=""
if [ -d "$ROOT/.learnings" ]; then
  RECENT_LEARNING="$(/usr/bin/find "$ROOT/.learnings" -name 'L-*.md' -type f -mmin -30 2>/dev/null | head -1 || true)"
fi

RECENT_SUBMIT=""
for f in "$ROOT"/competitions/*/submissions/LOG.md; do
  [ -f "$f" ] || continue
  if /usr/bin/find "$f" -mmin -60 2>/dev/null | grep -q .; then
    RECENT_SUBMIT="$f"
    break
  fi
done

[ -z "$RECENT_LEARNING" ] && [ -z "$RECENT_SUBMIT" ] && exit 0

echo "### Session retro nudge"
echo "Substantive activity detected this session (new learnings and/or recent submissions). Before ending, consider invoking the \`retrospect-session\` skill to extract 0-3 durable learnings, refresh LEARNINGS.md, and archive anything stale."
