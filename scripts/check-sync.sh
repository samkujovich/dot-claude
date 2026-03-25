#!/bin/bash
# SessionStart hook — warns if global settings haven't been synced in 24h

SYNC_FILE="$HOME/.claude/last-synced-at"

if [ ! -f "$SYNC_FILE" ]; then
  echo "⚠ Global Claude settings have never been synced. Run /sync-claude-global-settings"
  exit 0
fi

LAST_SYNC=$(cat "$SYNC_FILE")
LAST_SYNC_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$LAST_SYNC" +%s 2>/dev/null || date -d "$LAST_SYNC" +%s 2>/dev/null || echo 0)
NOW_EPOCH=$(date +%s)
DIFF=$(( NOW_EPOCH - LAST_SYNC_EPOCH ))

if [ "$DIFF" -gt 86400 ]; then
  echo "⚠ Global Claude settings last synced $(( DIFF / 3600 )) hours ago. Run /sync-claude-global-settings"
fi
