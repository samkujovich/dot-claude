# Coding Style

## Philosophy: Write as Little Code as Possible

Every other principle serves this one.

Prefer reusing existing code, utilities, and patterns over writing new ones. Make small, focused changes — don't refactor the world to add a feature. If the codebase already has a pattern for something, follow it. If a framework provides a mechanism, use it instead of rolling your own.

Don't build for hypothetical future requirements. Solve the problem in front of you. Three similar lines of code are better than a premature abstraction. You can always refactor later when the pattern is clear — and usually it turns out you don't need to.

## Principles

### 1. Ship Small, Iterate

Build MVPs and iterate. Deliver something small that works, then improve it. Small wins compound into big wins. Big bang releases after long periods of silence are a failure mode, not a strategy.

Everything ships incrementally. If a feature feels too big, break it down until each piece delivers value on its own.

### 2. Prove It Works

Every feature should have a way to know if it's working and why — or why not. This isn't just about tests (though those matter). It's about the full picture: tests, evals, observability, metrics.

Think at the feature level, not just the code level. Tests prove the code runs. But can you point to something that says "this solved the problem" or "this didn't"? If you can't answer that, you're not done.

For AI/agent work, this means structured evaluation — evals over vibes. Know when an agent is performing well and when it's degrading.

### 3. Defend the Why

Articulate pros and cons of approaches, pick one, and have a reason. The specific choice matters less than the reasoning behind it. A well-defended decision you disagree with is better than an unexamined one you happen to agree with.

Keep it lightweight — a PR description, a Linear ticket comment, a short summary in a thread. Not everything needs a formal decision doc. Save those for the truly consequential, irreversible choices.

When presenting options: show trade-offs, make a recommendation, defend it. Let the decision-maker decide.

### 4. Follow the Codebase

The engineers on the team are the experts on the code. Follow the practices they've established. If the codebase does something a certain way, do it that way — don't introduce a new pattern without a reason.

Before proposing changes, understand what already exists. Read the code, check for existing patterns and utilities, then build on top of them. Clean code and separation of concerns matter, but consistency with the existing codebase matters more.

### 5. Optimize for AI Tooling

Most code is AI-generated and that number is increasing. Keep this in mind at every level:

- **Documentation and tickets**: Write with the assumption that an AI agent will load it into context. Be explicit, structured, and unambiguous.
- **Code architecture**: Structure code so AI tools (Claude Code, Cursor, Codex) can understand and extend it. Small files, clear naming, obvious patterns.
- **Interfaces**: Design AI-friendly interfaces in all systems. Structured inputs/outputs, clear schemas, good error messages.

### 6. Security at the Boundary

Validate and sanitize all external input at the edge. Use schema validation for structured data. Inside the boundary, trust your own code.

For AI systems: security comes from purpose-built controls — not from asking the model nicely. Prompting tells the model what you want, not what it's allowed to do.

## How I Work

I lead the team — I spend less than 20% of my time writing code. When I'm in the code, I'm typically:

- Spiking on architecture to validate an approach before the team builds it
- Reviewing PRs to understand and catch issues
- Debugging production problems
- Contributing to team repos (Python now, possibly TypeScript)
- Building personal tools and scripts

## LLM Instructions

When writing or modifying code with Sam:

**DO:**

- Check the codebase for existing patterns before proposing new ones
- Make small, focused changes
- Follow whatever conventions the codebase already uses
- Reuse existing utilities and patterns

**DON'T:**

- Over-engineer solutions
- Refactor surrounding code when making a simple change
- Introduce new patterns when existing ones work
- Make changes beyond what was asked
- Build for hypothetical future requirements
