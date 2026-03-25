#!/bin/bash
set -e

REPO="https://github.com/samkujovich/dot-claude.git"
TARGET="$HOME/.claude"
TMPDIR=$(mktemp -d)

trap 'rm -rf "$TMPDIR"' EXIT

echo "Cloning dot-claude..."
git clone "$REPO" "$TMPDIR/dot-claude"

if [ -d "$TARGET/.git" ]; then
  echo "~/.claude is already a git repo — pulling latest..."
  cd "$TARGET"
  git pull --rebase
elif [ -d "$TARGET" ]; then
  echo "~/.claude exists but is not a git repo — merging..."
  cp -r "$TMPDIR/dot-claude/.git" "$TARGET/.git"
  cd "$TARGET"
  git checkout -- $(git ls-tree -r HEAD --name-only)
  echo "Merged. Existing untracked files are preserved."
else
  echo "Installing to ~/.claude..."
  mv "$TMPDIR/dot-claude" "$TARGET"
fi

if command -v bun &> /dev/null; then
  echo "Installing dependencies with bun..."
  cd "$TARGET" && bun install
else
  echo "bun not found — skipping dependency install. Run 'npm install' in ~/.claude manually."
fi

echo "Done! Your global Claude Code config is ready at ~/.claude"
