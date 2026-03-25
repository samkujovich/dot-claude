# Global Claude Code Configuration

This is Sam Kujovich's global Claude Code configuration. These files provide default preferences and context across all projects. Project-specific instructions live in each repo's own `CLAUDE.md`.

## Always Loaded

@PREFERENCES.md

## Reference Files (load on demand)

- `WHOAMI.md` — Who I am, my background, and what I'm working on
- `CODING_STYLE.md` — Engineering philosophy and preferred patterns

## Commands

- `bun lint` — Lint markdown files
- `bun format` — Auto-fix markdown lint issues

## Setup

To install, run:

```sh
curl -s https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
```
