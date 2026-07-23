# CLAUDE.md

Global instructions for Claude Code across all of Sam's projects. A project's own `CLAUDE.md` takes precedence where they conflict.

## Preferences

@PREFERENCES.md

## How to work

- **Discuss before implementing.** For non-trivial changes (new features, architectural decisions, multi-file refactors), present 2-3 options with tradeoffs and a recommendation, then wait for direction before writing code.
- **PR review.** When processing PR review comments or Bugbot findings: empirically test claims before agreeing (regex, edge cases, ordering), group fixes into logical commits, run lint + tests after each batch, and end with a handoff summary.
- **Voice.** The `my-writing-style` skill (anything written as Sam) and the `coding-style` skill (engineering conventions) carry the full specs and trigger automatically — follow them.

## Background

`WHOAMI.md` has Sam's role, history, and areas of expertise. Read it when a task needs that context (bios, outreach, framing).
