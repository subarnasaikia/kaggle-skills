#!/usr/bin/env bash
# install.sh — set up kaggle-skills in a Kaggle workspace directory.
# Usage: bash install.sh [target-dir]
#   target-dir defaults to the current directory.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$(pwd)}"

echo "kaggle-skills installer"
echo "  source : $REPO_DIR"
echo "  target : $TARGET"
echo ""

# ── Prerequisites ────────────────────────────────────────────────────────────

check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo "MISSING: $1 — $2"
    MISSING=1
  else
    echo "  ok: $1"
  fi
}

MISSING=0
echo "Checking prerequisites..."
check_cmd kaggle  "install: uv tool install --python 3.11 kaggle"
check_cmd uv      "install: curl -Lsf https://astral.sh/uv/install.sh | sh"
check_cmd python3 "install via uv or your system package manager"
check_cmd git     "install via your system package manager"

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "Install the missing tools above, then re-run install.sh."
  exit 1
fi

# Check kaggle auth
if [ ! -f "$HOME/.kaggle/access_token" ]; then
  echo ""
  echo "WARNING: ~/.kaggle/access_token not found."
  echo "  Create it: echo 'KGAT_...' > ~/.kaggle/access_token && chmod 600 ~/.kaggle/access_token"
  echo "  Get a token at: https://www.kaggle.com/settings/account (API section)"
  echo ""
fi

# ── Create target structure ──────────────────────────────────────────────────

echo ""
echo "Creating workspace structure in $TARGET ..."

mkdir -p \
  "$TARGET/.claude/hooks" \
  "$TARGET/.claude/skills" \
  "$TARGET/.learnings/archive" \
  "$TARGET/scripts" \
  "$TARGET/shared/utils" \
  "$TARGET/competitions"

# ── Copy files ───────────────────────────────────────────────────────────────

echo "Copying skills..."
cp -r "$REPO_DIR/.claude/skills/"* "$TARGET/.claude/skills/"

echo "Copying hooks..."
cp "$REPO_DIR/.claude/hooks/"*.sh "$TARGET/.claude/hooks/"

echo "Copying reference docs..."
cp "$REPO_DIR/.claude/KAGGLE_CLI_CHEATSHEET.md" "$TARGET/.claude/"
cp "$REPO_DIR/.claude/MCP_VS_CLI_GUIDE.md" "$TARGET/.claude/"

echo "Copying settings.json (skipping if already exists)..."
if [ ! -f "$TARGET/.claude/settings.json" ]; then
  cp "$REPO_DIR/.claude/settings.json" "$TARGET/.claude/"
else
  echo "  skipped (already exists — merge manually if needed)"
fi

echo "Copying scripts..."
cp "$REPO_DIR/scripts/kln" "$TARGET/scripts/"
cp "$REPO_DIR/scripts/_kln_digest.py" "$TARGET/scripts/"
cp "$REPO_DIR/scripts/new-competition.sh" "$TARGET/scripts/"

echo "Copying shared utilities..."
cp "$REPO_DIR/shared/utils/submit.py" "$TARGET/shared/utils/"

echo "Copying CLAUDE.md (skipping if already exists)..."
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$REPO_DIR/CLAUDE.md" "$TARGET/"
else
  echo "  skipped (already exists)"
fi

echo "Copying LEARNINGS.md (skipping if already exists)..."
if [ ! -f "$TARGET/LEARNINGS.md" ]; then
  cp "$REPO_DIR/LEARNINGS.md" "$TARGET/"
else
  echo "  skipped (already exists)"
fi

echo "Copying .learnings/README.md..."
cp "$REPO_DIR/.learnings/README.md" "$TARGET/.learnings/"

echo "Copying .gitignore (skipping if already exists)..."
if [ ! -f "$TARGET/.gitignore" ]; then
  cp "$REPO_DIR/.gitignore" "$TARGET/"
else
  echo "  skipped (already exists)"
fi

# ── Permissions ───────────────────────────────────────────────────────────────

echo "Making scripts executable..."
chmod +x "$TARGET/.claude/hooks/session-start.sh"
chmod +x "$TARGET/.claude/hooks/post-kaggle-action.sh"
chmod +x "$TARGET/.claude/hooks/stop.sh"
chmod +x "$TARGET/scripts/kln"
chmod +x "$TARGET/scripts/new-competition.sh"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done! kaggle-skills installed in $TARGET"
echo ""
echo "Next steps:"
echo "  1. Open Claude Code in $TARGET"
echo "  2. Run: /new-competition <your-competition-slug>"
echo "  3. Start competing"
echo ""
echo "Human CLI for learnings:"
echo "  $TARGET/scripts/kln add      # add a learning interactively"
echo "  $TARGET/scripts/kln list     # list all learnings"
echo "  $TARGET/scripts/kln search <term>"
