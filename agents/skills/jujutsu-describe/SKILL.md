---
name: jujutsu-describe
description: Describe the current jj revision with a proper commit message. Use when the user wants to create a commit message, describe changes, write a commit summary, prepare a commit description, or says "describe this revision", "what should I commit", "create commit message".
---

# Jujutsu Describe Skill

Generate a proper commit message for the current jj revision by analyzing recent commits and current changes.

## Step 1: Check Recent Commit Messages

Run this command to see the last 5 commit messages:

```bash
jj log --limit 5 -r @-
```

Analyze the commit message format from these commits to understand the pattern we use:
- What's the commit type prefix (feat, fix, refactor, chore, etc.)?
- Is there a scope in parentheses?
- How are titles formatted (length, capitalization)?
- Are there any ticket numbers like [VW-XXX]?

Extract this pattern information to reuse it consistently.

## Step 2: Analyze Current Changes

Run this command to see what's changed in the current working copy:

```bash
jj diff
```

Examine the output to understand what files were modified and what the changes do.

## Step 3: Determine Commit Type and Title

Based on the changes, determine the appropriate commit type:

- **feat** - New feature or functionality
- **fix** - Bug fix
- **refactor** - Code refactoring without behavior change
- **chore** - Maintenance, build changes, dependencies, tooling
- **docs** - Documentation only
- **test** - Test additions or changes
- **style** - Formatting, no code logic change

You can optionally include a scope in parentheses, e.g., `feat(auth)`, `fix(ui)`, `refactor(api)`.

## Step 4: Check for Previous Issue Reference

Look at the previous commit message (from Step 1). If it contains a ticket number in the format `[VW-XXX]` or similar:

- **Reuse the same ticket number** for consistency
- If no ticket number found but you're unsure if one should be used, ask the user

## Step 5: Draft the Commit Message

### Title Format

```
<type>(<scope>): < Title under 50 chars >
```

Examples:
- `feat(auth): add JWT authentication`
- `fix(ui): resolve button alignment`
- `refactor(api): simplify query builder`
- `chore(deps): update dependencies`
- `docs(readme): fix typo`

### Description (Optional)

Only add a description body (separate line after title) if:
- The change is non-obvious and needs context
- There are breaking changes or migrations
- There are related issues or follow-ups

Keep descriptions concise and informative.

## Final Output

Present the commit message to the user:

```
Commit message:
<title>

<optional description>

Use this message? [Y/n]
```

Wait for user confirmation before applying with `jj describe`.