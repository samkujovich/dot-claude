# dot-claude

This is Sam Kujovich's global Claude Code configuration. It applies to all projects and repositories. Project-specific instructions live in each project's own `CLAUDE.md`.

## Always Loaded

These files are included in every conversation:

- `@PREFERENCES.md` — Output formatting preferences (lists over prose, concise responses, terminal colors)

## Reference Files

Read these when relevant to the task at hand:

- `WHOAMI.md` — Background on Sam: contact, career history, projects, and areas of expertise
- `WRITING_STYLE.md` — Writing style guide for replicating Sam's voice
- `CODING_STYLE.md` — Coding conventions and engineering philosophy

## Global Settings

- `settings.json` — Tracked global config: default mode, effort level, permission allow-list (git commands), the SessionStart sync-check hook, and enabled plugins.
- `settings.local.json` — Machine-specific overrides. Gitignored, never pushed.

## Skills

- `/bootstrap` — Deep repository analysis and expertise bootstrap
- `/open-pr` — Turn done work on a branch into a high-quality Draft PR
- `/process-pr-review` — Work through a PR's review comments one at a time
- `/my-writing-style` — Draft/edit first-person writing in Sam's voice
- `/sync-claude-global-settings` — Sync `~/.claude` with the remote repo

Work-specific skills (`toolkit-review`, `acr-cross-check`) are kept local and gitignored — they hold internal engineering methodology and are not published here.

## Pushing Changes

`~/.claude` is the working tree for this repo. To push local edits:

```sh
cd ~/.claude
git status                  # see what changed
git add <files>             # stage specific files
git commit -m "<message>"
git push
```

Per-project memory under `~/.claude/projects/.../memory/` lives outside this repo and is not pushed by it. That's per-machine state.

## Setup

To install on a new machine (clones the repo and merges with any existing `~/.claude` data):

```sh
curl -fsSL https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
```
