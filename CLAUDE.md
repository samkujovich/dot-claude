# CLAUDE.md

This is Sam Kujovich's global Claude Code configuration. It applies to all projects and repositories. Project-specific instructions live in each project's own `CLAUDE.md`.

## Always Loaded

These files are included in every conversation:

- @PREFERENCES.md — Output formatting preferences (lists over prose, concise responses, terminal colors)

## Reference Files

Read these when relevant to the task at hand:

- `WHOAMI.md` — Background on Sam: contact, career history, projects, and areas of expertise
- `CODING_STYLE.md` — Coding conventions and engineering philosophy

## Global Settings

- `settings.local.json` — Claude Code permission allow-list (granular Bash command permissions for git operations, etc.)

## Setup

To install on a new machine (clones the repo and merges with any existing `~/.claude` data):

```bash
curl -fsSL https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
```