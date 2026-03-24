---
name: youtrack-search
description: Searches YouTrack from natural language or native query syntax and returns a concise report with the most relevant issues. Use when the user wants to find issues, triage work, or translate a plain-language query into YouTrack search.
---

# YouTrack Search

Use this skill for search-first YouTrack tasks.

## Input

Expected input: either
- natural language, or
- valid YouTrack query syntax

If the input is empty, ask what to search for.

## Workflow

1. Inspect available MCP tools for YouTrack.
2. Decide whether the input is natural language or native YouTrack syntax.
3. If natural language, translate it into a reasonable YouTrack query.
4. Execute the search with a sane limit.
5. If there are no results, broaden the query once.
6. For the top matches, fetch additional details and recent comments when useful.
7. Build a compact report with:
   - issue id
   - summary
   - assignee
   - last activity
   - notable blockers or decisions when available
8. If query parsing fails, explain the problem and show the user a few valid query examples.
9. Respond in the same language as the user's query.

## Constraints

- Max 20 search results in the initial list
- Max 10 issues for deeper enrichment
- Skip issues without permission
- Do not guess field names that the server does not support

## Output

Prefer a table for the main results and short notes below it for conclusions or next actions.
