## Version Control: Jujutsu (jj)

Use `jj` (Jujutsu), not git.

- **Never** use `git commit` or `git add`.
- **Before any code changes**, always check current revision description:
  `jj log --no-graph -r @ --template 'description'`
- Description must be non-empty. If it is empty, set it immediately:
  `jj describe -m "<description>"`
- If the new task/feature is semantically different from current description,
  create a new revision before editing:
  `jj new -m "<description>"`
- jj tracks changes automatically (no staging).
