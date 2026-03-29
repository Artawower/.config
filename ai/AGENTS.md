## Version Control: Jujutsu (jj)

This system uses `jj` (Jujutsu) instead of git. Rules:

- **Never** use `git commit` or `git add`
- **BEFORE making any code changes**: run `jj log --no-graph -r @ --template 'description'` to check the current revision description
- If the current task is semantically different from that description — run `jj new -m "<description>"` to create a new revision first
- jj tracks changes automatically, no staging needed
