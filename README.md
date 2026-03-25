# dot-claude

Dotfiles for [Claude Code](https://claude.ai/claude-code) — my global configuration for `~/.claude`.

## What is this?

This repo is version-controlled global configuration for Claude Code. It lives at `~/.claude` and provides personal preferences, coding style, and workflow automations to every Claude Code session. Project-specific instructions live in each project's own `CLAUDE.md`.

## Structure

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main entry point — declares always-loaded vs on-demand files |
| `PREFERENCES.md` | Output formatting and response style preferences |
| `WHOAMI.md` | Professional identity and background |
| `CODING_STYLE.md` | Engineering philosophy and preferred patterns |
| `settings.json` | Global Claude Code settings |
| `setup.sh` | One-line installer |

## Setup

```sh
curl -s https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
```

## Skills

| Skill | Description |
|-------|-------------|
| `/commit-and-push` | Lint, commit, push, and create/update a draft PR |
| `/sync-claude-global-settings` | Sync `~/.claude` with the remote repo |

## Inspiration

Inspired by [evantahler/dot-claude](https://github.com/evantahler/dot-claude).
