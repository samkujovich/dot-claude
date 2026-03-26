#!/usr/bin/env bash
set -euo pipefail

# Setup script for Sam's global Claude Code configuration.
# Clones the dot-claude repo into ~/.claude, preserving any
# existing Claude Code data (sessions, caches, projects, etc.).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
#   # or
#   bash setup.sh

REPO="https://github.com/samkujovich/dot-claude.git"
CLAUDE_DIR="$HOME/.claude"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "==> Setting up dot-claude in $CLAUDE_DIR"

# 1. Clone the repo to a temp directory
echo "==> Cloning $REPO..."
git clone "$REPO" "$TMP_DIR/dot-claude"

if [ -d "$CLAUDE_DIR" ]; then
  # 2. Existing ~/.claude — merge repo into it
  echo "==> Found existing $CLAUDE_DIR, merging..."

  if [ -d "$CLAUDE_DIR/.git" ]; then
    echo "==> $CLAUDE_DIR is already a git repo — pulling latest instead."
    git -C "$CLAUDE_DIR" pull --rebase origin main
    echo "==> Done. Already set up."
    exit 0
  fi

  # Move .git into the existing directory
  mv "$TMP_DIR/dot-claude/.git" "$CLAUDE_DIR/.git"

  # Checkout tracked files from the repo, without clobbering untracked data.
  cd "$CLAUDE_DIR"
  git checkout HEAD -- .

  echo "==> Merged repo files into existing $CLAUDE_DIR"
else
  # 3. Fresh install — just move the clone into place
  echo "==> No existing $CLAUDE_DIR found, installing fresh..."
  mv "$TMP_DIR/dot-claude" "$CLAUDE_DIR"
  echo "==> Installed to $CLAUDE_DIR"
fi

echo "==> Done! Your Claude Code global config is ready at $CLAUDE_DIR"
