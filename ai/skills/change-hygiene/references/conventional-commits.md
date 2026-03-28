# Conventional Commits for jj Revision Descriptions

Use conventional commit style as the default format for jj revision descriptions when the repository does not define a stronger local convention.

## Recommended Format

```text
type(scope): short imperative description
```

Scope is optional:

```text
type: short imperative description
```

Examples:
- `feat(agents): add coordinator orchestration policy`
- `fix(pi): correct sequential dispatch wording`
- `docs(skills): add change hygiene skill`
- `refactor(agents): simplify team definitions`
- `chore(config): update pi package settings`

## Types

### `feat`
Use for a new user-visible capability or workflow.

Examples:
- `feat(skills): add change hygiene skill`
- `feat(agents): add arbiter agent`

### `fix`
Use for a bug fix, broken behavior, or incorrect policy wording with real impact.

Examples:
- `fix(agents): stop implying generic parallel dispatch`
- `fix(config): correct default team selection`

### `docs`
Use for documentation-only changes.

Examples:
- `docs(agents): document coordinator routing policy`
- `docs(skills): add revision scope examples`

### `refactor`
Use for structural improvement without changing intended behavior.

Examples:
- `refactor(agents): simplify coordinator prompt structure`
- `refactor(skills): split references into smaller files`

### `chore`
Use for maintenance that is not a feature, fix, or refactor of core behavior.

Examples:
- `chore(config): reorder team definitions`
- `chore(repo): normalize markdown headings`

### `test`
Use for adding or adjusting tests.

Examples:
- `test(agents): add coordinator trigger coverage`
- `test(skills): add eval cases for change hygiene skill`

### `build`
Use for build-system, packaging, or dependency pipeline changes.

Examples:
- `build(repo): update packaging for skills`
- `build(ci): adjust release artifact generation`

### `ci`
Use for CI workflow changes.

Examples:
- `ci(repo): add skill validation step`
- `ci(actions): tighten markdown lint workflow`

### `perf`
Use for measurable performance improvements.

Examples:
- `perf(agents): reduce repeated context loading`
- `perf(skills): shrink default skill body context`

## Scope Guidance

Use a scope when it adds clarity. Good scopes in this repo include:
- `agents`
- `skills`
- `pi`
- `config`
- `docs`
- `repo`
- a specific area like `teams`, `chains`, `orchestration`

Skip the scope when it adds noise or when the affected area is already obvious.

Good:
- `docs(skills): add conventional commit examples`
- `fix: correct broken markdown link`

Bad:
- `feat(everything): lots of changes`
- `chore(misc): updates`

## jj-Specific Notes

In jj, revision descriptions are not just a final commit-message afterthought. They help decide whether work belongs in the current revision at all.

Before editing files:
1. read the current revision description
2. read the last 2-3 recent revisions for context
3. decide whether the new task matches the current revision scope
4. if it does not, run:

```bash
jj new -m "<description>"
```

## Message Quality Rules

A good description should be:
- imperative
- one logical change
- specific
- easy to scan in `jj log`

Prefer:
- `feat(agents): add research coordinator`
- `docs(skills): explain same-scope vs new-scope rule`

Avoid:
- `misc`
- `wip`
- `changes`
- `fix stuff`
- `agent updates and docs and cleanup`
