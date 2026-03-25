---
name: sync-claude-global-settings
description: Sync ~/.claude with the remote repo
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(date *)
---

# Sync Claude Global Settings

1. `cd ~/.claude`
2. `git fetch origin`
3. Stage and commit any local changes with a message like "sync: local changes"
4. `git pull --rebase origin main`
5. `git push origin main`
6. Write the current UTC timestamp to `~/.claude/last-synced-at`
