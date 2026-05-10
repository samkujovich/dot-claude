---
name: process-pr-review
description: Walk through the unresolved review comments on one of the user's GitHub pull requests one at a time, applying the user's accept/decline/defer decisions, batching all file edits into a single commit, then posting thread replies, resolving addressed threads, and re-requesting review. Use this skill whenever the user wants to systematically work through PR review feedback on a specific PR — phrases like "walk through the PR comments", "address the review feedback on PR #N", "let's go through Nate's review one by one", "process the review on this PR", "handle these review comments", "respond to the PR review", or any time they want to respond to a code review on an open PR they authored. This is distinct from general code review (where Claude is the reviewer) or general PR work — this skill is specifically for the author of a PR responding to comments left by reviewers. Use it even when the user phrases the request casually, as long as the context is clearly "I have review comments and I want to work through them." The skill orchestrates the workflow; the user remains the decision-maker on each individual comment.
---

# Process PR Review

Walk the user through the unresolved review comments on one of their open pull requests, helping them apply each as accept-as-suggested / accept-with-tweak / decline / defer, then batch the file edits into a single commit and handle all the GitHub-side bookkeeping (thread replies, resolves, re-requesting review).

The skill exists because the manual version is repetitive and high-overhead — fetching unresolved threads, mapping comment IDs to thread IDs, posting replies via REST, resolving via GraphQL, and re-requesting review are tedious to remember. The model handles judgment (categorizing comments, recommending accept/decline, drafting reply text). The skill removes the mechanical friction.

## Workflow

### 1. Get the PR

If the user gave a PR number, use it. Otherwise auto-detect from the current branch:

```bash
PR=$(bash scripts/pr_threads.sh detect-pr)
```

If detection fails (current branch has no PR), prompt the user for the number rather than guessing.

### 2. Fetch unresolved threads

```bash
bash scripts/pr_threads.sh fetch "$PR"
```

Returns a JSON array. Each entry has: `thread_id` (GraphQL), `comment_id` (REST), `author`, `path`, `line`, `body`, `is_outdated`.

Filter out bot reviewers (`cursor`, `github-actions`, `copilot-pull-request-reviewer`, `vercel`, `linear`, similar) by default — bot comments often need different handling and clutter the human-judgment loop. Mention the bot count up front so the user knows they exist:

> Found 22 unresolved threads from human reviewers + 3 from bots. Walking through the human ones; bots are excluded — address those separately if needed.

### 3. Categorize and overview before walking

Scan all human comments and present a quick taxonomy before starting the per-comment loop:

- **Wording**: small copy edits, suggestion blocks
- **Structural**: rearrange, add, or remove sections
- **Substantive**: changes the meaning, real disagreement, philosophical points
- **Nit**: minor stylistic preference, low-impact

Show the count and breakdown. This lets the user know what they're in for ("3 substantive ones to discuss, the rest are wording") and helps them mentally prepare.

### 4. Walk through one comment at a time

For each comment, present:

1. **Header**: `Comment N of M — Line X (one-line summary)`
2. **Current text** in the file. **Read it fresh from the file** — line numbers shift as earlier suggestions get applied, so don't rely on the comment's stated line number after the first edit. Match by content.
3. **Reviewer's suggestion** or comment body
4. **Diff**: what changes if accepted (call out the meaningful deltas, not just whitespace)
5. **Category**
6. **Recommendation** with a defense — accept exact, accept with tweak, decline, or defer

Wait for the user's decision on each before moving to the next. Don't batch presentations. The whole point of the per-comment loop is the back-and-forth.

When you recommend "accept with tweak," show the tweaked version explicitly, not just "accept but change X." The user should see the exact text they're approving.

### 5. Apply decisions as you go

- **Accept (exact or tweaked)**: Edit the file. Queue the reply text — short for simple acks ("Applied."), with a sentence of explanation when the tweak deviates from the suggestion ("Applied with one tweak — kept X for reason Y.").
- **Decline**: No file edit. Queue substantive reply text explaining the disagreement.
- **Defer**: No file edit. Queue reply text noting the deferral and where the discussion will happen.

Keep replies-to-post in memory (or write them to a temp scratch file if the list is long). Don't post anything to GitHub yet.

Track which threads will be **resolved** (accepted decisions) vs. **left unresolved** (declined or deferred). This matters: the team's etiquette is *"leave unresolved if you disagree"* — silent-resolving disagreement is hostile.

### 6. Self-review pass before commit

Once all comments are processed, read the final file(s) top-to-bottom. The user just made many sequential edits; small inconsistencies sneak in:

- Numbered lists off-by-one because an item was added/removed
- Section references pointing to deleted sections
- Doubled punctuation, orphaned em-dashes, broken markdown
- Internal duplications when content was moved

Surface anything you notice with line numbers and a recommended fix. **This step is non-negotiable** — it's the same self-review the team's PR standards prescribe ("you've reviewed your own diff top-to-bottom"). Skipping it undermines the whole point of the skill modeling the team's etiquette.

### 7. One commit, one push

Stage all edited files in a single commit. Sample message:

```text
docs(scope): address [reviewer]'s review feedback

- [bullet summary of meaningful changes]
- [one bullet per substantive change]

Refs: <LINEAR-ID>
```

Then push. **Do not amend prior commits or force-push** — that's hostile to a reviewer who is mid-read on the previous version. New commits, always.

### 8. Post replies and resolve threads

For each addressed thread: post the reply, then resolve the thread.
For each declined or deferred thread: post the reply, **leave the thread unresolved**.

```bash
# Write the body to a temp file (handles quotes, multi-line, code, etc.)
echo "Applied." > /tmp/reply.txt
bash scripts/pr_threads.sh reply "$PR" "$COMMENT_ID" /tmp/reply.txt
bash scripts/pr_threads.sh resolve "$THREAD_ID"   # only if accepted
```

Bodies are passed via file because reply text often has quotes, code, and multi-line content that's miserable to escape on the command line.

For efficiency, batch the calls in a single bash script that loops over the queued replies. But run the script in this turn, not as a series of separate `Bash` tool calls — running 20+ tool calls one at a time clutters the transcript and is slow.

### 9. Re-request review

```bash
bash scripts/pr_threads.sh request-review "$PR" "$REVIEWER"
```

By default, re-request only the reviewer whose comments you just addressed. Don't ping uninvolved reviewers — that's noise.

If multiple reviewers had comments and you addressed all of them in one pass, re-request all of them.

## Etiquette this skill encodes

These come from the team's published PR standards:

- **Always reply when resolving a comment.** Silent-resolves are invisible to the reviewer. Even a one-line "Applied." is enough.
- **Leave threads unresolved when the author disagrees.** Disagreement is fine; silent-resolving disagreement is not.
- **No "fix linting" commits during review.** Batch all changes from a review-feedback pass into one commit.
- **Re-request review after pushes.** Don't make the reviewer guess whether to re-look.
- **Self-review (read fresh) before pushing.** The author owns the final state.

If the user's instructions ever conflict with these, follow the user — but call out the deviation so they make the choice consciously.

## Edge cases

- **No unresolved threads**: Tell the user there's nothing to walk through. Offer to look at outdated or resolved threads if useful.
- **Outdated comments** (`is_outdated: true`): The code the comment anchored to has already changed. Surface them upfront so the user can decide whether to silent-resolve them (already addressed by a prior push) or skip them entirely.
- **Comments not on the current diff**: If the file content at the comment's path/line doesn't match the comment's `body` or expected anchor, surface as: *"Couldn't locate exactly — here's the comment, here's what's at that line now, your call."*
- **Multi-line `suggestion` blocks**: Replace the full anchored span, not just the first line. GitHub anchors suggestions to a line range, not a single line.
- **Line drift after edits**: As earlier suggestions get applied, line numbers shift. Always re-read the file (or rely on `Edit`'s exact-content matching) to find the current location of text — never trust the comment's stated line number after the first edit in this session.
- **User pushes mid-walkthrough**: If the user pushes while we're walking, the queue of pending replies/resolves still applies, but the diff state changed. Flag it and re-fetch threads if needed.
- **PR is in Draft state**: The skill still works on Drafts; comments are comments. But note that re-requesting review on a Draft is a no-op — GitHub doesn't notify reviewers on Draft PRs. Tell the user to flip the PR to Ready before the re-request will land.

## Bundled helpers

- `scripts/pr_threads.sh` — wraps the GraphQL/REST plumbing. Subcommands:
  - `detect-pr` — output the PR number for the current branch (or fail if none)
  - `fetch <PR>` — output a JSON array of unresolved review threads
  - `reply <PR> <COMMENT_ID> <BODY_FILE>` — post a reply on a thread
  - `resolve <THREAD_ID>` — mark a thread resolved
  - `request-review <PR> <REVIEWER>` — re-request review
