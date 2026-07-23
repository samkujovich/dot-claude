---
name: review-panel
description: Run a panel of AI-native senior-expert subagents (principal-engineer, qa-expert, product-manager, cto, cpo) over a PR, branch diff, plan, design, or project — each forming an independent opinion at a high bar — then synthesize their verdicts into one ranked report. Use when the user wants a thorough multi-perspective review, a "panel review", a "get the personas to review this", or a go/no-go read on a change or plan.
user-invocable: true
---

# Review Panel

Fan out several reviewer personas over the same target, run them **independently** (so their opinions stay uncorrelated), then merge what they find into one consolidated verdict. The personas live in `~/.claude/agents/` — this skill orchestrates them.

## Step 1 — Establish the target and shared context

Figure out what's being reviewed and assemble one context bundle that every persona will see:

- **A PR** (`/review-panel <number>` or a PR URL): `gh pr view <n>`, `gh pr diff <n>`, and the existing review threads (so personas don't re-flag already-answered comments).
- **The current branch** (no argument): `git diff origin/main...HEAD` plus the branch's commit messages.
- **A plan / design / project** (a path or a description): read the relevant files or the pasted plan.

Capture the diff/plan, the title + intent, and any existing review discussion. If the target is ambiguous, ask before spawning agents.

## Step 2 — Pick the panel

Default by target type (the user can override by naming personas, or say "full panel" for all five):

| Target | Panel |
| --- | --- |
| Code / PR / feature | `principal-engineer`, `qa-expert`, `product-manager` |
| Plan / design / strategy / direction | `cto`, `cpo`, `principal-engineer`, `product-manager` |
| Large or cross-cutting change | all five |

For an Arcade **worker toolkit** PR, prefer the dedicated `toolkit-review` skill instead — it has the toolkit checklist and verification gate this skill doesn't.

## Step 3 — Fan out (in parallel, blind)

Spawn the chosen personas **concurrently** — issue all the subagent calls in a single message so they run at once. Give each the **same** shared-context bundle and its own task, and do **not** show any persona another's output. Independence is the whole point: uncorrelated context windows are what make the panel worth more than one reviewer.

Each persona already knows its lens and output format from its own definition. Your job per call is only to hand it the context and the ask ("review this against your bar; findings + verdict").

## Step 4 — Synthesize

Collect every persona's findings, then:

- **Deduplicate** overlapping findings into one entry; note which personas raised each.
- **Rank** by severity (blockers first), not by persona.
- **Mark agreement vs. conflict.** Multiple personas independently flagging the same thing = higher confidence. Personas disagreeing = surface the disagreement explicitly; that tension is signal, not noise to average away.
- **Do not inflate.** These are candidate findings, not ground truth — a persona can be confidently wrong off a stale diff. Flag anything high-severity as "verify before acting."

## Step 5 — Report

Lead with a one-line **panel verdict** (ship / ship-with-changes / rethink), then:

1. **Blockers** — must-fix, with `file:line — issue — why — which personas — confidence`.
2. **Should-fix** — worth addressing before merge/commit.
3. **Consider** — nice-to-haves and open questions.
4. **Disagreements** — where personas split, and the call to make.

Keep it scannable — tables and tight bullets. End by naming the 1–2 things to verify first.
