# dot-claude

Sam Kujovich's global Claude Code configuration (`~/.claude`). Applies to all projects; project-specific instructions live in each project's own `CLAUDE.md`.

## What's here

**Agent instructions** (loaded by Claude Code every session)

- `CLAUDE.md` — global behavioral instructions
- `PREFERENCES.md` — output/formatting preferences (imported by `CLAUDE.md`)

**Reference docs** (read on demand)

- `WHOAMI.md` — background on Sam
- `WRITING_STYLE.md` — the voice spec (applied by the `my-writing-style` skill)

**Config**

- `settings.json` — tracked global config: default mode, effort level, permission allow/deny lists, hooks (SessionStart sync check + git guard), enabled plugins
- `settings.local.json` — machine-specific overrides (gitignored, never pushed)
- `scripts/` — hook scripts (`check-sync.sh`, `git-guard.sh`)

**Skills** (`skills/`, progressive-disclosure procedures)

- `/bootstrap` — deep repository analysis + expertise bootstrap
- `/coding-style` — Sam's engineering conventions
- `/my-writing-style` — draft/edit writing in Sam's voice
- `/open-pr` — turn done work into a high-quality Draft PR
- `/process-pr-review` — work through a PR's review comments one at a time
- `/sync-claude-global-settings` — sync `~/.claude` with this repo

Work-specific skills (`toolkit-review`, `acr-cross-check`) are gitignored — internal methodology, kept local and not published here.

## Pushing changes

`~/.claude` is the working tree for this repo. Use the `/sync-claude-global-settings` skill, or manually:

```sh
cd ~/.claude
git status                  # see what changed
git add <files>             # stage specific files
git commit -m "<message>"
git push
```

Per-project memory under `~/.claude/projects/.../memory/` lives outside this repo and is not pushed. That's per-machine state.

## Setup

To install on a new machine (clones the repo and merges with any existing `~/.claude` data):

```sh
curl -fsSL https://raw.githubusercontent.com/samkujovich/dot-claude/main/setup.sh | bash
```
