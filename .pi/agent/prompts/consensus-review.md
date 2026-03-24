---
description: Multi-model code review via the consensus-review skill
---

Load and execute the `consensus-review` skill.

Default scope:
- review uncommitted changes in the current repository (`git diff HEAD`)

Store per-model reports in `plans/review/` and return the final consolidated verdict in Russian.
