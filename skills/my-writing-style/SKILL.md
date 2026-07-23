---
name: my-writing-style
description: Apply Sam's writing voice to first-person writing — drafting or editing emails, Slack messages, LinkedIn posts, follow-ups, and any writing sent as himself. Use whenever writing as Sam, or when he says a draft "doesn't sound like him" or asks to edit for voice. This skill operationalizes the voice spec in WRITING_STYLE.md.
---

# Apply Sam's Writing Voice

This skill is the **applicator**. It takes the voice described in `~/.claude/WRITING_STYLE.md` (the spec — the outline of how Sam talks) and uses it to draft or rewrite a specific piece of writing.

Division of labor: **`WRITING_STYLE.md` = what Sam's voice is. This skill = how to produce writing in it.** Don't restate the spec's rules here — read them from the spec so there's one source of truth.

## Process

### 1. Load the spec

Read `~/.claude/WRITING_STYLE.md` first. It holds the authoritative voice, tone, register-by-context table, signature phrases, and the "sounds like AI" tells to scrub. Everything below assumes those rules.

### 2. Pin the register

Identify which register the piece is, because the rules shift by context (see the spec's "Tone by Context" table):

- **Email** — internal quick-ask (often greeting-free, 1-3 sentences), recruiting/cold outreach (warmer, fuller, `Hi [Name],` → `Best,\nSam`), or vendor/customer.
- **Slack** — most casual, greeting-free, sign-off-free, capitalization matched to energy.
- **LinkedIn / long-form** — one idea developed fully, sourced data, personal narrative, ends on a question or a plain next step.

When the register is ambiguous, ask before drafting rather than guessing.

### 3. Draft directionally

Produce a first pass that's roughly right in the correct register. Don't over-polish — polish reads as AI.

### 4. Scrub against the spec

Edit the draft against the spec's lists. The high-frequency passes:

- Replace every em-dash (`—`) with a spaced hyphen (` - `).
- Cut filler openers, elevated vocabulary, and corporate hedge phrases.
- Remove the AI tells from the spec's "Things That Don't Sound Like Sam" and "The AI Test."
- Compress (Slack/email): drop the throat-clearing first sentence, remove hedges ("I think," "it seems"), cut any sentence that restates another, prefer active voice.
- Match opener and sign-off to the register.
- Don't manufacture typos or forced lowercase — his real writing is clean.

### 5. Run the acceptance bar

The test is: **would Sam send this without changes?** If there's any residue of AI formality or corporate polish, the answer is no — keep editing.

### 6. Iterate without defending

When Sam pushes back, revise fast. Don't defend the previous version — just produce a better one.
