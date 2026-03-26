---
name: bootstrap
description: Deep repository analysis and expertise bootstrap
user-invocable: true
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash(ls *)
  - Bash(cat *)
  - Bash(git log *)
  - Bash(git branch *)
---

# Bootstrap

Analyze this repository as if you're a principal engineer on your first day. Build a complete understanding and present a structured summary covering each of the following sections.

## 1. What does this project do?

One-paragraph elevator pitch. What problem does it solve and for whom?

## 2. How is it structured?

Key directories and where things live. Show the top-level structure and explain what each major directory contains.

## 3. What's the tech stack?

Languages, frameworks, major dependencies. Note versions where relevant.

## 4. How do I run it?

Build, start, and test commands. Environment setup requirements (env vars, config files, local services).

## 5. How does it get deployed?

CI/CD pipeline, environments, deploy process. Look for Dockerfiles, CI configs, deploy scripts.

## 6. What are the key patterns?

Code organization conventions, architectural patterns, naming conventions. What would a new contributor need to follow?

## 7. Where's the data?

Databases, external services, APIs it talks to. Look for connection configs, client initializations, schema definitions.

## 8. What's the testing approach?

How tests are structured, what frameworks are used, how to run them. Note any eval suites for AI/agent work.

## 9. What are the entry points?

Where does execution start? Main files, route definitions, handler registrations.

## 10. What's the dependency graph?

How do the major pieces connect to each other? What calls what?

---

Present the summary, then await further instructions.
