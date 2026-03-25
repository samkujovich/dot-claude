# Coding Style

## Philosophy

Write clear, simple code that solves the problem at hand. Avoid over-engineering and premature abstraction. The best code is code you don't have to write.

## Principles

### 1. Hexagonal Architecture

Separate core business logic from external dependencies. Use ports and adapters to keep the domain clean and testable. This enables swapping providers (LLM, database, messaging) without touching business logic.

### 2. Multi-Agent System Design

- Agents should be composable and single-responsibility
- Use structured evaluation to validate agent behavior
- Implement guardrails at system boundaries, not scattered through business logic
- Dual-layer validation: fast pattern matching + LLM-based evaluation

### 3. Platform Engineering

- Reduce KTLO burden through automation and reliability improvements
- Measure what matters: lead time, incident frequency, deployment frequency
- Build internal platforms as products — with clear interfaces and documentation

### 4. Test Against the Real Thing

- Prefer integration tests over mocks where feasible
- Test agent behavior with evaluation suites, not just unit tests
- Validate at system boundaries (user input, external APIs)

### 5. Keep Dependencies Explicit

- 12-Factor app principles: config via environment variables, stateless processes
- Pin dependencies. Understand what you're importing.
- Prefer standard library and well-maintained packages over rolling your own

### 6. Security at the Boundary

- Validate and sanitize all external input at the edge
- Use schema validation (Zod, Pydantic) for structured data
- Never rely on prompt engineering alone for security in AI systems
