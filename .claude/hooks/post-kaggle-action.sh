#!/usr/bin/env bash
# PostToolUse hook — matched on Bash tool calls touching kaggle.
# Emits a short nudge back to Claude only for submission / push-style actions.
set -euo pipefail

INPUT="$(cat - 2>/dev/null || true)"
CMD="$(printf '%s' "$INPUT" | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || true)"

[ -z "$CMD" ] && exit 0

case "$CMD" in
  *"kaggle competitions submit"*)
    echo "### Post-submit nudge"
    echo "A competition submission just completed. Invoke the \`post-submission-review\` skill to poll the score, diff against prior best, update submissions/LOG.md, and decide whether to capture a learning."
    ;;
  *"kaggle kernels push"*)
    echo "### Kernel push nudge"
    echo "A Kaggle kernel was pushed. Poll status with \`kaggle kernels status <user>/<slug>\` until complete. If this produced a submission artifact, chain into \`post-submission-review\` afterwards."
    ;;
  *"kaggle competitions download"*)
    echo "### Download nudge"
    echo "Competition data downloaded. Competitions CLI does NOT support --unzip — remember to unzip manually. Also consider \`kaggle config set -n competition -v <slug>\` so future commands can drop the slug."
    ;;
  *)
    exit 0
    ;;
esac
