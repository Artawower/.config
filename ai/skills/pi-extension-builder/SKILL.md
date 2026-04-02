---
name: pi-extension-builder
description: Build, debug, and package pi coding-agent extensions. Use when the user wants to create or modify a pi extension, register custom tools or commands, handle lifecycle events, or package extensions for sharing.
---

# Pi Extension Builder

> **Freshness**: Fetch live docs when implementing event handlers, stateful tools, file-mutating tools, or custom rendering:
> `fetch_content https://raw.githubusercontent.com/badlogic/pi-mono/refs/heads/main/packages/coding-agent/docs/extensions.md`

---

## Pre-conditions

1. Check for existing extensions before creating a new one:
   - Global: `~/.pi/agent/extensions/`
   - Project-local: `.pi/extensions/`
2. Confirm with the user: global or project-local scope?
3. Are npm dependencies needed? → determines extension structure below.

---

## What are you building?

| Goal                                      | Tool                                                                      |
| ----------------------------------------- | ------------------------------------------------------------------------- |
| Custom tool for the LLM                   | `pi.registerTool()`                                                       |
| Slash command `/mycommand`                | `pi.registerCommand()`                                                    |
| Block a tool call                         | `pi.on("tool_call")` → `return { block: true, reason? }`                  |
| Modify tool call arguments                | `pi.on("tool_call")` → mutate `event.input` in place (return only blocks) |
| Modify tool output                        | `pi.on("tool_result")` → `return { content?, details?, isError? }`        |
| Intercept user input                      | `pi.on("input")` → `return { action: "transform", text: ... }`            |
| Inject context before each turn           | `pi.on("before_agent_start")` → `return { message?, systemPrompt? }`      |
| User interaction (confirm, select, input) | `ctx.ui.*`                                                                |
| Custom TUI rendering                      | `renderCall` / `renderResult`                                             |
| Register dynamic skills/prompts/themes    | `pi.on("resources_discover")` → `return { skillPaths?, promptPaths?, themePaths? }` |
| Override built-in tool (bash, read, write…) | `pi.registerTool({ name: "bash", ... })` — same name replaces built-in |
| Persist state across sessions             | `pi.appendEntry()` / `details` pattern                                    |
| Share via npm/git                         | `package.json` with `pi` key                                              |

---

## Extension structure

**Single file** (simple extensions):

```
~/.pi/agent/extensions/my-extension.ts
```

**Directory** (multiple modules):

```
~/.pi/agent/extensions/my-extension/
├── index.ts
└── helpers.ts
```

**Package** (needs npm dependencies):

```
~/.pi/agent/extensions/my-extension/
├── package.json    # with "pi" key
├── node_modules/
└── src/index.ts
```

`package.json` for a package:

```json
{
  "name": "my-extension",
  "dependencies": { "zod": "^3.0.0" },
  "pi": { "extensions": ["./src/index.ts"] }
}
```

---

## Extension skeleton

```ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import {
  truncateHead,
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
} from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { StringEnum } from "@mariozechner/pi-ai"; // required for Google model compatibility

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "my_tool",
    label: "My Tool",
    description: "What this tool does (shown to LLM)",
    promptSnippet:
      "One-liner for Available tools section — omit and LLM won't discover this tool",
    parameters: Type.Object({
      action: StringEnum(["list", "add"] as const),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      if (signal?.aborted)
        return { content: [{ type: "text", text: "Cancelled" }] };

      // throw to signal failure — returning any value always succeeds (isError: false)
      const { stdout } = await pi.exec("git", ["status"], { signal });

      const truncation = truncateHead(stdout, {
        maxLines: DEFAULT_MAX_LINES,
        maxBytes: DEFAULT_MAX_BYTES,
      });
      return { content: [{ type: "text", text: truncation.content }] };
    },
  });

  pi.on("session_shutdown", async () => {
    // close connections, file watchers, timers
  });
}
```

---

## Workflow

1. **Define the goal** — tool, command, event handler, or a combination
2. **Choose scope** — global vs project-local
3. **Choose structure** — single file / directory / package
4. **Scaffold** — `export default function (pi: ExtensionAPI) { ... }`
5. **Register capabilities** — `registerTool`, `registerCommand`, `pi.on`
6. **Handle state** — decide if `details` pattern is needed for reconstruction
7. **Test** — `pi -e ./extension.ts` or `/reload` after placing in auto-discovery path
8. **Package if needed** — add `package.json` with `pi` key for sharing

---

## Critical pitfalls

- **Google compatibility**: use `StringEnum(["a", "b"] as const)`, never `Type.Enum()` or union types
- **Error signaling**: `throw new Error(...)` from `execute()` to report failure — returning any value always succeeds (`isError: false`)
- **Output truncation**: use `truncateHead`/`truncateTail` from `@mariozechner/pi-coding-agent` for output over 50KB/2000 lines — untruncated output breaks context
- **promptSnippet**: without it, the LLM won't see the tool in the `Available tools` section and won't discover it
- **tool_call mutation**: return `{ block: true }` to block, mutate `event.input` in place to modify args — return value does NOT modify arguments
- **Non-interactive modes**: always check `ctx.hasUI` before calling UI methods
- **State and branches**: store state in tool result `details`; reconstruct from `ctx.sessionManager.getBranch()` in BOTH `session_start` AND `session_tree` (tree navigation fires `session_tree`, not `session_start`)
- **File-mutating tools**: wrap with `withFileMutationQueue()` — tool calls run in parallel, without the queue concurrent edits to the same file will clobber each other
- **sendUserMessage during streaming**: must pass `{ deliverAs: "steer" | "followUp" }` — calling without it while agent is streaming throws
- **Cleanup**: always register `session_shutdown` for connections, file watchers, timers
- **Reload is terminal**: code after `await ctx.reload()` is not guaranteed to run — treat it as the last statement

---

## Placement and scope

| Path                                | Scope                 | Hot-reload      |
| ----------------------------------- | --------------------- | --------------- |
| `~/.pi/agent/extensions/*.ts`       | Global                | Yes (`/reload`) |
| `~/.pi/agent/extensions/*/index.ts` | Global (subdirectory) | Yes             |
| `.pi/extensions/*.ts`               | Project-local         | Yes             |
| `pi -e ./path.ts`                   | One-time test         | No              |

---

## Available imports (no npm install needed)

| Package                         | Purpose                                                                                           |
| ------------------------------- | ------------------------------------------------------------------------------------------------- |
| `@mariozechner/pi-coding-agent` | `ExtensionAPI`, event types, type guards, `truncateHead`, `truncateTail`, `withFileMutationQueue` |
| `@sinclair/typebox`             | `Type.Object`, `Type.String`, etc. for parameters                                                 |
| `@mariozechner/pi-ai`           | `StringEnum` for Google-compatible enums                                                          |
| `@mariozechner/pi-tui`          | `Text`, `Box`, `List`, `Input`, `Select`                                                          |
