# Refactor Policy

## What this skill optimizes for (priority order)

1. **Readability** — Code reads like prose. Names reveal intent. Functions do one thing and are named for that one thing.
2. **Simplicity** — The simplest solution that works. Flat over nested. Guard clauses over else-chains. No speculative abstractions (YAGNI).
3. **No duplication** — Every piece of knowledge has one authoritative home. This includes structural duplication, not just copy-paste.
4. **Consistency** — Follow conventions already present in the codebase. Match existing patterns before introducing new ones.
5. **Idiomatic** — Use the language and framework as intended. Don't fight the ecosystem's conventions.
6. **Architecture** — Responsibilities live where they belong. No inappropriate coupling. Clear boundaries between layers.

## Code smells catalog

**Bloat**
- Functions or classes that do more than one thing
- Functions longer than ~20–30 lines
- Parameter lists with more than 3–4 parameters
- Classes with too many fields or methods

**Duplication**
- Copy-pasted logic, even if slightly modified
- The same concept expressed in multiple places
- Parallel structures that always change together

**Poor naming**
- Names that describe *how* instead of *what* (`processData`, `handleStuff`, `flag`, `temp`)
- Misleading names where the name says one thing and the code does another
- Abbreviations that require mental decoding
- Comments that explain what the code does — a sign the code needs a better name, not a comment

**Complexity**
- Deeply nested conditionals (more than 2–3 levels)
- Long boolean expressions without named variables
- Mixed abstraction levels inside the same function
- Logic that only makes sense with a comment explaining it

**Coupling**
- A function reaching into internals of another module
- A class that knows too much about another class
- Changes in one place that ripple to many others

**Inconsistency**
- Different conventions for the same kind of thing
- Patterns that exist in the codebase but aren't followed here

## Techniques

| Technique | When to apply |
|-----------|---------------|
| Extract Function | Fragment of logic that can be named and understood independently |
| Inline Function | Indirection that adds no clarity |
| Extract Variable | Expression that needs a name to be understood |
| Rename | Name does not reveal intent |
| Move Function / Class | Responsibility lives in the wrong place |
| Extract Class / Module | Unit does more than one thing |
| Inline Class | Class so thin it adds no value |
| Introduce Parameter Object | Parameters that always travel together |
| Replace Conditional with Lookup | Switch / if-else dispatching on a type |
| Replace Nested Conditional with Guard Clauses | Deep nesting that hides the happy path |
| Consolidate Duplicate Code | Same structure appearing in multiple places |
| Remove Dead Code | Code that is never reached |

Start with low-risk techniques (Rename, Extract Variable, Extract Function) before structural ones (Move, Extract Class, Replace Conditional). Structural changes affect more call sites and are harder to revert.

## Hard rules

- One refactoring at a time. Tests green before the next step.
- Do not change behavior. If you find a bug, note it — fix it in a separate pass after refactoring.
- Do not add features, new tests beyond characterization, or unrelated improvements in the same pass.
- Do not over-engineer. Refactor toward the design the *next* concrete change needs — not toward theoretical perfection.
- Follow existing codebase conventions even when you disagree. Consistency beats personal preference.
- If a refactoring would take more than an hour without completing, it is too large — split it.
- Respond in the user's language.
