---
name: commit-and-push
description: Lint, commit, push, and create/update a draft PR
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(bun lint)
  - Bash(bun format)
---

# Commit and Push

1. Run `bun lint` in the project root. If it fails, run `bun format` and re-check.
2. Run `git status` to see all changes.
3. Stage files by name — never use `git add -A` or `git add .`.
4. Create a commit. If the user provided a message, use it. Otherwise, generate a concise message summarizing the changes. Always include the co-author trailer:

```
Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

5. Push to the remote.
6. If on a non-main branch, create a draft PR with `gh pr create --draft` or update the existing one. Use a clear title and description.
