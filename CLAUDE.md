# CLAUDE.md

This is Sam Kujovich's global Claude Code configuration. It applies to all projects and repositories. Project-specific instructions live in each project's own `CLAUDE.md`.

## Discussion Before Implementation

For non-trivial changes (new features, architectural decisions, multi-file refactors), discuss tradeoffs and approach BEFORE writing code or opening PRs. Default to a short design discussion with 2-3 options + tradeoffs, then wait for direction.

## Always Loaded

These files are included in every conversation:

- @PREFERENCES.md — Output formatting preferences (lists over prose, concise responses, terminal colors)

## Reference Files

Read these when relevant to the task at hand:

- `WHOAMI.md` — Background on Sam: contact, career history, projects, and areas of expertise
- `WRITING_STYLE.md` — Writing style guide for replicating Sam's voice
- `CODING_STYLE.md` — Coding conventions and engineering philosophy

## Writing & Drafting

### Writing Voice

When drafting messages, posts, docs, or interview feedback: avoid AI-sounding phrasing (no "mantra for a baseball movie" style metaphors, no "detour" framings, no generic enthusiasm). Match the user's direct, technical voice. When in doubt, produce a shorter draft and ask before adding flourish.

## Workflows

### PR Review Workflow

When processing PR review comments or Bugbot findings: empirically test claims before agreeing (regex, edge cases, ordering bugs), group fixes into logical commits, run lint+tests after each batch, and produce a handoff summary at the end.

## Global Settings

- `settings.local.json` — Claude Code permission allow-list (granular Bash command permissions for git operations, etc.)

## Setup

To install on a new machine (clones the repo and merges with any existing `~/.claude` data):

```bash
curl -fsSL https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
```