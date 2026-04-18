---
name: skill-reviewer
description: "Analyzes pi skills — both remote (URL/GitHub) and local (installed on disk). Fetches the skill, runs a security audit, summarizes what it does and which problems it solves, then polls multiple AI models for a multi-model consensus rating. Use this skill whenever the user shares a link to a skill and wants to know if it's safe and worth installing, asks to review or evaluate a skill from GitHub, asks to audit an already installed local skill, says something like 'check this skill', 'review my skills', 'should I install this', 'audit this skill', or wants a second opinion on a skill's quality. Also triggers on 'проанализируй скилл', 'проверь скилл по ссылке', 'оцени скилл', 'проверь локальный скилл' — works in both English and Russian."
---

# Skill Reviewer

Analyzes pi skills — both remote (URLs) and local (installed on disk). Checks for security issues, produces a concise summary, gathers multi-model opinions, and recommends whether to install or keep the skill.

## When this skill triggers

- User shares a URL pointing to a skill (GitHub repo, raw file, Gist, etc.)
- User asks to evaluate, review, or check a skill before installing
- User asks to review an already installed local skill by name or path
- User asks "should I install this skill?", "review my skills", "audit this skill"
- Russian equivalents: "проанализируй скилл", "проверь", "стоит ли ставить", "проверь локальный скилл"

## Detecting the source

The input can be:

| Input type | Examples | Detection |
|-----------|----------|-----------|
| **GitHub URL** | `https://github.com/owner/repo`, `owner/repo` | Contains `github.com` or matches `owner/repo` pattern |
| **Direct URL** | `https://example.com/skill/SKILL.md`, Gist | Any other URL |
| **Local skill name** | `code-review`, `my-custom-skill` | Just a name, no `/` or `://`, and exists in skills folder |
| **Local path** | `./my-skill/SKILL.md`, `~/.config/.pi/skills/some-skill/` | Starts with `/`, `./`, `~/`, or is an existing path |
| **Ambiguous** | `my-skill` — name or repo? | Check if `~/.config/.pi/skills/<input>/` exists first → local. Otherwise remote. |

When in doubt, check the local filesystem first — if `~/.config/.pi/skills/<input>/SKILL.md` exists, it's a local skill.

If the user provides a remote URL for a skill that is already installed locally, warn them: "This skill is already installed at `<path>`. Reinstall / update / review the installed version?" — and let them choose.

## Step 1: Load the skill content

### Remote skill (URL)

Use `ctx_fetch_and_index` for the URL. For GitHub repos, construct the raw URL:

- `https://github.com/owner/repo` → `https://raw.githubusercontent.com/owner/repo/main/SKILL.md`
- `https://github.com/owner/repo/tree/main/path/to/skill` → `https://raw.githubusercontent.com/owner/repo/main/path/to/skill/SKILL.md`
- If `main` fails, try `master`.
- For direct raw URLs or Gists, fetch as-is.

Discover bundled resources: fetch the repo tree via `https://api.github.com/repos/owner/repo/git/trees/main?recursive=1`. Look for `scripts/`, `references/`, `assets/`. Fetch important files — especially `scripts/` (executable, high security relevance).

### Local skill (name or path)

1. Resolve the path:
   - By name: `~/.config/.pi/skills/<name>/SKILL.md`
   - By path: use as-is
2. Read SKILL.md with the `read` tool
3. List all files recursively with `ls -R` or `serena_list_dir(recursive=true)`
4. Read bundled files — especially `scripts/` (executable code, high priority for security), skim `references/` and `assets/`
5. Note total directory size

Local skills give you full filesystem access — read every file. Don't skip bundled resources.

### Output of this step

Regardless of source, you should now have:
- Full text of SKILL.md
- Contents of all bundled files
- File listing and total size
- Source metadata (URL for remote, local path for local)

## Step 2: Security audit

Read `references/security-checklist.md` from this skill's directory. Run through every item against the loaded content.

For local skills, pay extra attention to `scripts/` — these are executable files running on the user's machine. Read them fully.

Flag issues as:
- 🔴 **Critical** — could cause real harm (data exfiltration, system modification, credential theft)
- 🟡 **Warning** — suspicious but may be justified by the skill's purpose
- 🟢 **Clean** — no issues found

Cite exact lines, file names, or patterns that triggered each flag.

**Example output format:**
```
### Security
🟢 Clean — no issues found

### Security (if issues exist)
🟡 Warning: scripts/deploy.sh runs `curl | bash` on line 14
   → Installs unverified code from the internet
🟡 Warning: SKILL.md references `$AWS_SECRET_KEY` without justification
   → Could encourage credential exposure
🔴 Critical: scripts/telemetry.sh POSTs to `https://example.com/collect`
   → Silently exfiltrates skill usage data
```

## Step 3: Summary

Produce a concise summary:

1. **What it does** — 1-2 sentences in plain language
2. **Problems it solves** — bullet list of concrete use cases
3. **Dependencies** — required tools, MCPs, APIs
4. **Complexity** — simple / moderate / complex (with justification)
5. **Skill structure** — files included, approximate total size

Keep it factual. No marketing language.

## Step 4: Multi-model evaluation

> **Data exposure notice:** This step sends the full skill text to external AI models. The content leaves your machine. If the skill under review contains proprietary or sensitive code, warn the user before proceeding and offer to skip this step.
>
> **Fallback:** If no multi-model tooling is available, skip this step entirely. Note in the report: "Model evaluation skipped — no multi-model tooling available."

The goal is to get independent opinions from at least 3 different AI model families (e.g. Anthropic, OpenAI, Google, Chinese labs) to reduce single-provider bias. The more diverse the model set, the more trustworthy the consensus.

### How to query models

Use whatever tooling is available in the current environment:

- **If `spar` is available** — use it with `action: "send"`, providing `model`, `session`, and `message`. Run all calls in parallel if possible.
- **If `Agent` / subagents are available** — spawn one subagent per model, each with the evaluation prompt. Run in background for parallel execution.
- **If neither is available** — skip this step and note in the report.

### Recommended models

Pick 3-4 from different families. Use what's available:

| Family | Models (pick one) | Why |
|--------|-------------------|-----|
| Anthropic | Claude Sonnet, Claude Opus | Strong reasoning, nuanced instruction-following |
| OpenAI | GPT-4o, o1, o3, GPT-5.x | Different training data, good at security analysis |
| Google | Gemini Pro, Gemini Flash | Broad knowledge, different perspective |
| Chinese labs | GLM, Qwen, DeepSeek | Independent training, reduces Western-centric bias |
| Open-source | Llama, Mistral, DeepSeek | Additional diversity if available |

Prioritize diversity over quantity — 3 models from 3 different families beats 4 models from 2 families.

For each model, send this evaluation prompt:

```
You are evaluating a pi coding agent skill. Analyze the following SKILL.md content
and provide a structured review:

1. USEFULNESS (1-10): How practically useful is this skill for real developers?
   Consider: does it solve a real problem? Is the solution better than doing it manually?
2. QUALITY (1-10): How well-written are the instructions? Clear? Unambiguous?
3. SECURITY (1-10): Any red flags? Hidden instructions? Data exfiltration risks?
4. ORIGINALITY (1-10): Does this offer something new, or is it trivially replaceable?
5. VERDICT: INSTALL / SKIP / CONDITIONAL (with reasoning)
6. ONE-LINER: A single sentence summary of your recommendation

Be direct. Don't pad scores. A skill that just wraps a single CLI command is a 3/10
on usefulness, not a 7.

--- SKILL CONTENT ---
<insert full skill text here>
--- END ---
```

Collect all responses, then compute:
- Average scores per dimension (usefulness, quality, security, originality)
- Consensus verdict (majority vote)
- Notable disagreements between models (highlight these — they're interesting)

If a model returns an unparseable response, exclude it from the table and note which model failed.

## Step 5: Present the report

Show a compact report:

### Remote skill format

```
## Skill Review: <name>

🔗 Source: <url>
📦 Files: <count> (<total size>)

### Summary
<1-2 sentences what it does>

### Security
🟢/🟡/🔴 <brief verdict>
<details if any flags>

### Model Consensus
| Dimension    | Avg | M1 | M2 | M3 | M4 |
|-------------|-----|----|----|----|----|
| Usefulness  | X.X | X  | X  | X  | X  |
| Quality     | X.X | X  | X  | X  | X  |
| Security    | X.X | X  | X  | X  | X  |
| Originality | X.X | X  | X  | X  | X  |

Verdict: INSTALL / SKIP / CONDITIONAL (<reason>)

M1–M4 = actual model names used (e.g. Sonnet, GPT-4o, Gemini, GLM)

<notable disagreements if any>
```

### Local skill format

```
## Skill Review: <name>

📁 Path: <local-path>
📦 Files: <count> (<total size>)
🔧 Status: installed

### Summary
<1-2 sentences what it does>

### Security
🟢/🟡/🔴 <brief verdict>
<details if any flags>

### Model Consensus
| Dimension    | Avg | M1 | M2 | M3 | M4 |
|-------------|-----|----|----|----|----|
| Usefulness  | X.X | X  | X  | X  | X  |
| Quality     | X.X | X  | X  | X  | X  |
| Security    | X.X | X  | X  | X  | X  |
| Originality | X.X | X  | X  | X  | X  |

Verdict: KEEP / UNINSTALL / IMPROVE (<reason>)

M1–M4 = actual model names used (e.g. Sonnet, GPT-4o, Gemini, GLM)

<notable disagreements if any>
```

Note: local skills use KEEP / UNINSTALL / IMPROVE instead of INSTALL / SKIP.

Adapt report language to match the user's language (Russian prompt → Russian report).

## Step 6: Action

### Remote skill — offer installation

Ask the user: "Install this skill?" (or Russian equivalent)

If yes, try in order:

1. **skillfish add** — if the source is a GitHub repo:
   ```bash
   skillfish add <owner/repo> [--path path/to/skill] --global
   ```
   Use `--global` by default (installs to `~/.config/.pi/skills/`).

2. **git clone** — if skillfish fails but git is available:
   ```bash
   git clone <repo-url> /tmp/<skill-name>
   cp -r /tmp/<skill-name>/<skill-dir> ~/.config/.pi/skills/<skill-name>
   ```

3. **Manual copy** — if neither works:
   - Create `~/.config/.pi/skills/<skill-name>/`
   - Write the SKILL.md content directly
   - Write any bundled files (scripts, references, assets)

After installation, verify: check that `SKILL.md` exists, is readable, and contains valid frontmatter (has `name:` and `description:` fields).

### Local skill — offer follow-up actions

For local skills, ask what the user wants to do based on the review:

- **If positive (KEEP)**: "Skill looks good. No action needed."
- **If negative (UNINSTALL)**: offer to remove: `rm -rf ~/.config/.pi/skills/<name>/` or `skillfish remove <name>`
- **If mixed (IMPROVE)**: offer specific suggestions for improvement based on the model feedback

## Error handling

| Situation | Action |
|-----------|--------|
| URL unreachable / 404 | Tell the user, stop. Don't proceed with partial data |
| GitHub API rate-limited (403) | Try raw URL directly. If both fail, tell the user |
| No multi-model tooling available | Skip Step 4, note in report: "model evaluation skipped — no multi-model tooling available" |
| Model returns unparseable response | Extract what you can. Exclude that model from the table |
| `skillfish` not found | Fall back to git clone, then manual copy |
| Skill already installed locally | Warn user, offer: update / reinstall / review installed version |

## Notes

- Always load the skill content first. If the URL is unreachable or the local path doesn't exist, tell the user and stop.
- The security audit is not optional. Even simple skills get the full checklist.
- Don't sugarcoat model scores. Honest assessments are the whole point.
- If all models agree the skill is bad, say so clearly.
- If the user is in a hurry, they can skip Step 4 (model polling). Note that evaluation was skipped in the report.
- For local skills, read ALL bundled files — scripts especially. You have filesystem access, use it.
