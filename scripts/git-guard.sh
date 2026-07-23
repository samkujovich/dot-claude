#!/bin/bash
# PreToolUse guard for Bash commands. Warn-only — it never blocks a command,
# it only prints a caution into context before a destructive or trunk-write
# git operation so Claude reconsiders. Hard denials (force push, catastrophic
# `rm -rf`) live in settings.json, not here.
#
# Reads the tool-call JSON on stdin; greps the raw payload (best-effort, no jq
# dependency). Always exits 0.

input=$(cat)

case "$input" in
*"git reset --hard"* | *"git clean -f"* | *"git checkout -- ."*)
  echo "⚠️  Destructive git command detected — it discards uncommitted work and cannot be undone. Confirm this is intended before running."
  ;;
esac

if printf '%s' "$input" | grep -q "git commit"; then
  branch=$(git branch --show-current 2>/dev/null)
  case "$branch" in
  main | master)
    echo "⚠️  Committing directly to '$branch'. If this repo uses feature branches, create one first. (Trunk repos like dot-claude are fine.)"
    ;;
  esac
fi

exit 0
