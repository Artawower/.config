# Security Checklist for Skill Review

When reviewing a skill, check every item below. Be thorough but fair — a skill that reads files to process them isn't inherently dangerous, but one that silently sends those files somewhere is.

## Data Exfiltration

- [ ] Does the skill instruct the agent to send data to external URLs, APIs, or services? If yes, is this clearly disclosed and necessary for the skill's purpose?
- [ ] Are there hidden or obfuscated URLs (base64, hex, split strings)?
- [ ] Does it try to read sensitive files (SSH keys, .env, credentials, wallet files) that aren't relevant to its stated purpose?
- [ ] Does it instruct the agent to upload files, paste content to pastebins, or use `curl`/`wget` to POST data externally?
- [ ] Does it reference environment variables containing secrets, tokens, or API keys without a legitimate need?

## System Modification

- [ ] Does it modify system files outside the project directory (e.g., /etc, ~/.ssh, system binaries)?
- [ ] Does it install packages or software without explicitly telling the user?
- [ ] Does it modify shell profiles (.bashrc, .zshrc, rc.xsh) or startup scripts?
- [ ] Does it create cron jobs, launch agents, or systemd services?
- [ ] Does it try to disable security tools (antivirus, firewall, sudo checks)?

## Code Execution

- [ ] Does it run arbitrary code from the internet (piping curl to shell, eval of fetched content)?
- [ ] Does it use `eval`, `exec`, or dynamic code execution in ways that could be exploited?
- [ ] Does it download and execute binaries or scripts without verification (checksum, signature)?
- [ ] Does it run commands with sudo or elevated privileges?

## Agent Behavior Manipulation

- [ ] Does it try to override the agent's safety instructions or system prompt?
- [ ] Does it instruct the agent to hide actions from the user or lie about what it's doing?
- [ ] Does it try to establish persistence (ask the agent to remember things across sessions without disclosure)?
- [ ] Does it try to sandbox-escape or access tools it shouldn't?

## Supply Chain

- [ ] Does it reference external packages with pinned versions, or could it pull arbitrary versions?
- [ ] Does it depend on unusual or little-known packages that could be typosquatting?
- [ ] Are the dependencies reasonable for what the skill claims to do?

## Privacy

- [ ] Does it collect telemetry, analytics, or usage data?
- [ ] Does it reference the user's personal information (name, email, IP) in ways unrelated to the skill's purpose?
- [ ] Does it store data in unexpected locations?

## Rating Guidelines

- 🔴 **Critical** flag = recommend against installation unless the user explicitly accepts the risk
- 🟡 **Warning** = document clearly, let the user decide
- 🟢 **Clean** = no issues found across all categories
