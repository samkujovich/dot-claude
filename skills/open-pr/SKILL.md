---
name: open-pr
description: Take work that's "done" on a branch and turn it into a high-quality Draft pull request that meets the team's published bar — Linear-linked, with a description in the canonical "Summary / Design decisions / Scope / Test plan" pattern, and verified against the six non-negotiables before promotion. Use this skill whenever the user signals they want to ship code as a PR — phrases like "open a PR for this", "ship this", "make a PR", "draft the PR for me", "package this up", "PR this", "let's open a PR", "I'm done, let's get this reviewed", "create a pull request", or anytime the user has working code and wants it on GitHub for review. Use it even when the user phrases it casually ("PR time", "let's ship") as long as the context is clearly "I have code, make it a PR." This is distinct from `process-pr-review` (responding to comments after a PR exists) and from general `code-review` (Claude as reviewer). The skill is state-aware — it picks up wherever the user is in the lifecycle (uncommitted code → committed → pushed → Draft → Ready) and moves them forward, not always from scratch.
---

# Open PR

Turn working code on a branch into a Draft pull request that meets the team's published bar (`docs/docs/announcements/2026-04-24-what-a-good-pr-looks-like.md`), then orchestrate the move from Draft to Ready for Review.

The skill exists because every step of the "done coding → Ready PR" workflow is repetitive and easy to skip:
- Linking to the Linear ticket
- Writing a description in the team's canonical pattern (#985 — Summary / Design decisions / Scope / Test plan)
- Verifying the six non-negotiables before promotion
- Self-review before push
- Watching CI and addressing Bugbot before flipping to Ready

The model handles judgment (drafting the description, summarizing the diff, recommending Draft vs. Ready). The skill orchestrates the state machine: figure out where the user is, and move them one step forward.

## Workflow

The skill is state-aware. Start by figuring out where the user is, then jump in at the right step.

### State detection (always start here)

Run these in parallel and collect the answers:

```bash
git status --short                                 # uncommitted changes?
git rev-parse --abbrev-ref HEAD                    # current branch name
git log --oneline origin/main..HEAD 2>/dev/null    # commits ahead of main
git remote get-url origin                          # repo
gh pr view --json number,isDraft,url 2>/dev/null   # PR for this branch?
```

Branch this on the result:

| State | Skip to |
|---|---|
| Uncommitted changes or unpushed commits | Step 1 (get the work onto GitHub) |
| Branch pushed, no PR | Step 2 (confirm Linear linkage) |
| Draft PR exists | Step 5 (promotion checklist) |
| Ready PR exists | Surface this — skill is the wrong tool, redirect to `process-pr-review` if comments are pending |

### 1. Get the work onto GitHub

If there are uncommitted changes, help commit them. If commits exist but aren't pushed, push them. Skip whichever sub-step doesn't apply.

Commit messages should:
- Use a conventional-commits prefix (`feat`, `fix`, `docs`, `chore`, etc.) — nice to have, not required, but the team's example PR uses them
- Reference the Linear ticket (extract from branch name if possible, or ask)
- Be specific about what changed and why

Sample:

```text
feat(coordinator): add User Source DB model + migration

Adds Postgres tables and SQLAlchemy models for User Source persistence.
Schema aligns with the GRO-60 domain enums.

Refs: GRO-63
```

For multi-commit branches with messy WIP commits, ask the user whether they want to clean up before pushing. Don't rebase or squash without explicit permission — destructive git operations require a clear yes.

### 2. Confirm Linear linkage

Every PR ties to a Linear ticket. **No ticket = no PR.** Try to extract the ticket ID:

1. From the branch name. Branches typically use lowercase Linear's "copy git branch name" output (e.g. `engtop-165/...` or `samkujovich/too-739-...`). Match `[a-zA-Z]+-\d+` and uppercase the prefix → `ENGTOP-165`, `TOO-739`.
2. From recent commit messages on the branch (`Refs:`, `Resolves:`, or inline IDs)
3. From the user, if neither auto-detects

If you can't find one, **stop and ask the user**:

> I couldn't find a Linear ticket linked to this branch. The team's standard is no ticket = no PR. Either (a) tell me the Linear ID, or (b) we should pause here while you create one. Which?

Don't guess. Don't fabricate a ticket ID. The non-negotiable is real — bypassing it defeats the purpose.

### 3. Draft the PR description

Use the **#985 canonical pattern**. Read the diff (`git diff origin/main...HEAD`) to populate it:

```markdown
## Summary

<One paragraph in plain English: what's the job to be done? Not "refactors X" — "users hit a 500 when Y, this fixes it." Pull from the Linear ticket if it has good framing.>

## Changes

- `path/to/file.ext`: what changed and why
- `path/to/other.ext`: what changed and why
<File-by-file at a level a reviewer can scan in 30 seconds. Not every file — the meaningful shape.>

## Design decisions

<Optional but encouraged — separate from the Summary. The decisions hardest to reconstruct from code: trade-offs, alternatives considered, patterns mirrored from elsewhere, what's intentionally out of scope.>

## Test plan

- [ ] <specific verification step>
- [ ] <another specific step>
- [ ] <post-deploy verification if applicable>
<Specific and verifiable. Not "tests pass" — "go test ./internal/foo green" or "click 'Connect Slack' on a workspace with 100+ channels, confirm no 500.">

Refs: <LINEAR-ID>
```

**Quality bar for the description** — match what the team's good-PR post calls out:

- Plain-English "why," not just "what"
- Scope is stated explicitly, including what's NOT in the PR if relevant ("No DAO changes — those are GRO-64")
- References to prior PRs in a series, if applicable
- Test plan has specific, verifiable steps
- Sensitive-path PRs (auth, permissions, billing, migrations, workflow files) include a **Risk** section with blast radius and mitigations

**For agent-authored work**, add the disclosure footer:

```markdown
---

🤖 Generated with [Claude Code](https://claude.com/claude-code); author is accountable for every line.
```

Show the user the draft description. Let them edit. Don't open the PR until they're happy.

### 4. Open as Draft

Open as Draft by default. Title format:

```text
<type>(<scope>): <one-line description> (<LINEAR-ID>)
```

Examples:
- `feat(coordinator): User Source DB model + migration (GRO-63)`
- `fix(engine): scope tools/list to allow-listed tools (GRO-41)`
- `docs(announcements): add "What a Good PR Looks Like" post (ENGTOP-165)`

```bash
gh pr create --draft \
  --title "<title>" \
  --body "$(cat /tmp/pr_body.md)"
```

(Use a temp file for the body — quotes and multi-line content escape badly inline.)

After opening, surface:
- The PR URL
- That CI is starting
- That Cursor Bugbot will review the Draft automatically
- The next steps before promotion

### 5. The promotion checklist (Draft → Ready)

This is the heart of the skill. Before flipping Draft → Ready, verify the six non-negotiables. Some are mechanical (you can check them); some require asking the user.

**The six:**

1. **Linked to a Linear ticket.** ✓ Verify the title or body has the ID. Mechanical check.
2. **You understand every change in the diff.** ✗ Ask: *"Have you read every change in the diff and can explain why each one is there? Specifically: any blocks an agent wrote that you'd struggle to defend in review?"*
3. **Runs locally and was tested through the end-user path.** ✗ Ask: *"Have you exercised this through the path a user will take? Not just unit tests — clicked through the dashboard, ran the auth flow, called the API the way the caller will?"*
4. **CI is green.** ✓ Mechanical: `gh pr checks <PR>` — confirm `Merge ready` is green and all relevant per-app checks pass. Skipped checks (e.g., `Coordinator` on a docs-only PR) are fine.
5. **You've reviewed your own diff top-to-bottom.** ✓ Run a self-review pass yourself first (see below), then confirm with the user.
6. **You'd merge it yourself.** ✗ Ask: *"If a teammate said LGTM right now, would you hit the merge button immediately? If not, what's blocking?"*

If any non-negotiable fails, **stop and report**. Don't flip to Ready.

**Self-review pass (non-negotiable #5)**:

Read every changed file top-to-bottom (use `Read`). The user just made a coherent change but small inconsistencies sneak in:

- Internal references pointing to deleted sections
- Numbered lists off-by-one after additions/removals
- Comments referencing old function names after a rename
- Test data that doesn't match the new code
- Doubled punctuation, orphaned em-dashes

Surface anything you notice with line numbers and a recommended fix. The user decides what to address.

**Bugbot/AI review handling**:

Before flipping to Ready, check whether Cursor Bugbot has reviewed and whether its comments are addressed:

```bash
gh pr view <PR> --json reviews --jq '.reviews[] | select(.author.login | test("cursor|bot"; "i"))'
```

If Bugbot left comments and they aren't addressed, surface them and offer to walk through them via the `process-pr-review` skill before promoting. Don't flip to Ready while Bugbot has unresolved findings — they're meant to be a first-pass filter.

### 6. Flip Draft → Ready

Once the six non-negotiables pass:

```bash
gh pr ready <PR>
```

Then surface:
- The PR URL
- Confirmation it's now Ready for Review
- Suggest reviewers based on touched paths (use CODEOWNERS if available, otherwise the user picks)
- Re-request review if previously reviewed (rarely applicable on first promotion, but possible)

## Edge cases

- **Branch already has a PR**: The skill is the wrong tool. If the PR is a Draft and the user wants to promote, jump to step 5. If it's Ready, redirect: *"This PR is already Ready. If you want to address review comments, the `process-pr-review` skill is what you want."*
- **No Linear ticket exists**: The team's rule is no ticket = no PR. Stop and ask. Don't bypass.
- **Multi-commit branch with messy WIP commits**: Ask before rewriting history. Squashing destructively without explicit permission is a footgun.
- **Branch is behind main**: Offer to rebase or merge before opening. Default to whichever the team uses (rebase preferred for clean history).
- **Sensitive-path PR (auth/permissions/billing/migrations/workflow files)**: Surface this early. Recommend adding a **Risk** section to the description with blast radius and mitigations. Ask the user to think through who needs to review beyond CODEOWNERS.
- **Agent-authored code on the branch**: Verify the user actually understands every change before promoting. The line *"an agent wrote it, I'm not sure why"* is the explicit anti-pattern; surface it directly if you suspect the user is in that state.
- **Branch is dirty (uncommitted changes that aren't part of the PR)**: Ask the user whether to include them, stash them, or skip them. Don't auto-commit unrelated work into the PR.
- **Dependabot / renovate / chore PRs**: For trivial dependency bumps the full description pattern is overkill. A one-line summary + the auto-generated changelog is fine. Don't force the #985 template onto a Renovate PR.

## What good looks like (reference)

A reviewer should be able to open the PR and immediately answer:
1. **What is the job to be done?** (from Summary)
2. **What did you change?** (from Changes / file list)
3. **How do I verify it?** (from Test plan)
4. **What's risky?** (from Risk note for sensitive paths)
5. **What ticket does this trace to?** (from Linear link)

If the reviewer would need to ask any of these, the description isn't done.

## Etiquette this skill encodes

From the team's PR standards (`docs/docs/announcements/2026-04-24-what-a-good-pr-looks-like.md`):

- **The reviewer is the customer.** Every choice the skill makes serves the reviewer's time and attention, not the author's convenience.
- **Draft by default.** Drafts give CI and Bugbot a chance to flag issues before a human is involved.
- **Six non-negotiables, no exceptions.** The skill checks what it can check and asks about what it can't. It doesn't open a PR that fails any of them.
- **Self-review before promotion.** The author owns the final state. Skipping self-review undermines the whole bar.
- **No fix-linting commits during review.** Get it clean before going Ready, not after.
