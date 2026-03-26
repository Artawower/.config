import { appendFile, readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";

const DEFAULT_SERVER = "https://ntfy.sh";
const DEFAULT_PRIORITY = "high";
const DEFAULT_TAGS = ["computer"];
const DEFAULT_SETTLE_MS = 4000;
const STATE_FILE = fileURLToPath(new URL("./ntfy-state.json", import.meta.url));
const DEBUG_FILE = fileURLToPath(new URL("./ntfy-debug.log", import.meta.url));

const USER_TURN_PATTERNS = [
    /\?\s*$/m,
    /\b(do you want|would you like|should i|which option|which one|which approach|how would you like)\b/i,
    /\b(can you|could you|please provide|please share|please confirm|confirm whether|let me know|tell me)\b/i,
    /\b(choose|select|pick|decide|approve|clarify)\b/i,
    /\b(i need|need from you|waiting for your|waiting on you|before i continue)\b/i,
];

const STATUS_ONLY_PATTERNS = [
    /\b(done|completed|finished|all set|successfully)\b/i,
    /\b(subagent|background task|idle|validation passed)\b/i,
];

function trimTrailingSlash(value) {
    return value.replace(/\/+$/, "");
}

function projectNameFromDirectory(directory) {
    const parts = directory.split("/").filter(Boolean);
    return parts.at(-1) ?? "workspace";
}

function normalizeTags(value) {
    if (!value) {
        return DEFAULT_TAGS;
    }

    const tags = value.split(",").map((tag) => tag.trim()).filter(Boolean);
    return tags.length > 0 ? tags : DEFAULT_TAGS;
}

function normalizeData(result, fallback) {
    return result?.data ?? fallback;
}

function truncate(value, maxLength = 180) {
    if (value.length <= maxLength) {
        return value;
    }

    return `${value.slice(0, maxLength - 1)}…`;
}

function sanitizeHeaderValue(value) {
    return value
        .replace(/[\r\n]+/g, " ")
        .replace(/[^\x20-\x7E]/g, "")
        .replace(/\s+/g, " ")
        .trim();
}

function compareMessages(a, b) {
    return a.info.time.created - b.info.time.created;
}

function extractText(parts) {
    return parts
        .filter((part) => part.type === "text" && !part.ignored)
        .map((part) => part.text.trim())
        .filter(Boolean)
        .join("\n\n")
        .trim();
}

function statusMeansActive(status) {
    return status?.type === "busy" || status?.type === "retry";
}

function ptyIsRelevant(pty, rootDirectory, worktree) {
    return pty.status === "running"
        && (pty.cwd.startsWith(rootDirectory) || pty.cwd.startsWith(worktree));
}

function loadConfig(directory) {
    const topic = process.env.OPENCODE_NTFY_TOPIC?.trim();

    return {
        topic,
        server: trimTrailingSlash(process.env.OPENCODE_NTFY_SERVER?.trim() || DEFAULT_SERVER),
        token: process.env.OPENCODE_NTFY_TOKEN?.trim(),
        priority: process.env.OPENCODE_NTFY_PRIORITY?.trim() || DEFAULT_PRIORITY,
        tags: normalizeTags(process.env.OPENCODE_NTFY_TAGS),
        click: process.env.OPENCODE_NTFY_CLICK?.trim(),
        settleMs: Number(process.env.OPENCODE_NTFY_SETTLE_MS || DEFAULT_SETTLE_MS),
        requireQuietPty: process.env.OPENCODE_NTFY_REQUIRE_QUIET_PTY === "true",
        debug: process.env.OPENCODE_NTFY_DEBUG === "true",
        projectName: projectNameFromDirectory(directory),
    };
}

function createLogger(enabled) {
    return {
        async debug(entry) {
            if (!enabled) {
                return;
            }

            await appendFile(
                DEBUG_FILE,
                `${JSON.stringify({ time: new Date().toISOString(), ...entry })}\n`,
                "utf8",
            );
        },
    };
}

function createStateRepository() {
    return {
        async read() {
            try {
                return JSON.parse(await readFile(STATE_FILE, "utf8"));
            }
            catch {
                return {};
            }
        },
        async write(state) {
            await writeFile(STATE_FILE, `${JSON.stringify(state, null, 2)}\n`, "utf8");
        },
        hasNotification(state, sessionID, messageID) {
            return state.notifications?.[sessionID]?.messageID === messageID;
        },
        async rememberNotification(state, sessionID, messageID) {
            await this.write({
                ...state,
                notifications: {
                    ...(state.notifications ?? {}),
                    [sessionID]: {
                        messageID,
                        time: Date.now(),
                    },
                },
            });
        },
    };
}

function createPublisher(config) {
    return {
        async publish({ message, sessionTitle }) {
            const titlePrefix = `OpenCode · ${config.projectName}`;
            const safeHeaderTitle = sanitizeHeaderValue(titlePrefix) || "OpenCode";
            const decoratedMessage = sessionTitle
                ? `[${config.projectName}] ${sessionTitle}\n\n${message}`
                : message;
            const headers = {
                Title: safeHeaderTitle,
                Priority: config.priority,
                Tags: sanitizeHeaderValue(config.tags.join(",")),
            };

            if (config.token) {
                headers.Authorization = `Token ${config.token}`;
            }

            if (config.click) {
                headers.Click = sanitizeHeaderValue(config.click);
            }

            const response = await fetch(`${config.server}/${config.topic}`, {
                method: "POST",
                headers,
                body: decoratedMessage,
            });

            if (!response.ok) {
                throw new Error(`ntfy publish failed (${response.status}): ${await response.text()}`);
            }
        },
    };
}

function createSessionAnalyzer(client, directory, worktree) {
    async function getSession(id) {
        return client.session.get({
            path: { id },
            query: { directory },
            responseStyle: "data",
        });
    }

    async function getRootSession(sessionID) {
        let current = await getSession(sessionID);

        while (current?.parentID) {
            current = await getSession(current.parentID);
        }

        return current;
    }

    async function getDescendantSessionIds(rootSessionID) {
        const ids = new Set([rootSessionID]);
        const queue = [rootSessionID];

        while (queue.length > 0) {
            const currentID = queue.shift();
            if (!currentID) {
                continue;
            }

            const children = normalizeData(await client.session.children({
                path: { id: currentID },
                query: { directory },
                responseStyle: "data",
            }), []);

            for (const child of children) {
                if (ids.has(child.id)) {
                    continue;
                }

                ids.add(child.id);
                queue.push(child.id);
            }
        }

        return ids;
    }

    async function hasActiveRelatedWork(rootSession) {
        const descendantIDs = await getDescendantSessionIds(rootSession.id);
        const statusMap = normalizeData(await client.session.status({
            query: { directory },
            responseStyle: "data",
        }), {});

        for (const id of descendantIDs) {
            if (statusMeansActive(statusMap[id])) {
                return true;
            }
        }

        return false;
    }

    async function hasRelevantRunningPty(rootSession) {
        const ptys = normalizeData(await client.pty.list({ responseStyle: "data" }), []);
        return ptys.some((pty) => ptyIsRelevant(pty, rootSession.directory, worktree));
    }

    async function getMessages(rootSessionID) {
        return normalizeData(await client.session.messages({
            path: { id: rootSessionID },
            query: { directory, limit: 30 },
            responseStyle: "data",
        }), []).sort(compareMessages);
    }

    async function resolveLatestTurn(rootSessionID) {
        const messages = await getMessages(rootSessionID);
        const latestUserCreated = messages
            .filter((message) => message.info.role === "user")
            .reduce((latest, message) => Math.max(latest, message.info.time.created), 0);

        const assistantMessages = messages.filter((message) => (
            message.info.role === "assistant"
            && message.info.time.created >= latestUserCreated
        ));

        for (let index = assistantMessages.length - 1; index >= 0; index -= 1) {
            const message = assistantMessages[index];
            const text = extractText(message.parts);

            if (!text && !message.info.error) {
                continue;
            }

            return {
                id: message.info.id,
                error: message.info.error,
                text,
                fallback: false,
            };
        }

        if (assistantMessages.length > 0) {
            const latestAssistant = assistantMessages.at(-1);
            return {
                id: latestAssistant.info.id,
                error: latestAssistant.info.error,
                text: "",
                fallback: true,
            };
        }

        if (latestUserCreated > 0) {
            return {
                id: `user-turn-${latestUserCreated}`,
                error: undefined,
                text: "",
                fallback: true,
            };
        }

        return {
            id: `quiet-session-${rootSessionID}`,
            error: undefined,
            text: "",
            fallback: true,
        };
    }

    return {
        getRootSession,
        hasActiveRelatedWork,
        hasRelevantRunningPty,
        resolveLatestTurn,
    };
}

function isUserTurn(turn) {
    if (!turn) {
        return false;
    }

    if (turn.error || turn.fallback) {
        return true;
    }

    if (!turn.text) {
        return false;
    }

    const normalized = turn.text.trim();
    if (!normalized) {
        return false;
    }

    if (USER_TURN_PATTERNS.some((pattern) => pattern.test(normalized))) {
        return true;
    }

    if (STATUS_ONLY_PATTERNS.some((pattern) => pattern.test(normalized))) {
        return false;
    }

    return false;
}

function buildPreview(turn) {
    if (turn.error) {
        return "OpenCode needs your attention.";
    }

    if (turn.fallback) {
        return "OpenCode is waiting for your input.";
    }

    return truncate(turn.text);
}

export const NtfyPlugin = async ({ directory, worktree, client }) => {
    const config = loadConfig(directory);

    if (!config.topic) {
        console.warn("[opencode-ntfy] OPENCODE_NTFY_TOPIC is not set; ntfy notifications are disabled.");
        return {};
    }

    const logger = createLogger(config.debug);
    const stateRepository = createStateRepository();
    const publisher = createPublisher(config);
    const analyzer = createSessionAnalyzer(client, directory, worktree);

    return {
        event: async ({ event }) => {
            if (event.type !== "session.idle") {
                return;
            }

            try {
                const sessionID = event.properties.sessionID;
                await logger.debug({ stage: "idle-received", sessionID });

                await Bun.sleep(Number.isFinite(config.settleMs) ? config.settleMs : DEFAULT_SETTLE_MS);

                const rootSession = await analyzer.getRootSession(sessionID);
                if (!rootSession) {
                    await logger.debug({ stage: "skip", reason: "root-session-missing", sessionID });
                    return;
                }

                if (rootSession.id !== sessionID) {
                    await logger.debug({
                        stage: "skip",
                        reason: "child-session-idle",
                        sessionID,
                        rootSessionID: rootSession.id,
                    });
                    return;
                }

                if (await analyzer.hasActiveRelatedWork(rootSession)) {
                    await logger.debug({
                        stage: "skip",
                        reason: "related-sessions-active",
                        sessionID,
                        rootSessionID: rootSession.id,
                    });
                    return;
                }

                if (config.requireQuietPty && await analyzer.hasRelevantRunningPty(rootSession)) {
                    await logger.debug({
                        stage: "skip",
                        reason: "pty-active",
                        sessionID,
                        rootSessionID: rootSession.id,
                    });
                    return;
                }

                const latestTurn = await analyzer.resolveLatestTurn(rootSession.id);
                if (!isUserTurn(latestTurn)) {
                    await logger.debug({
                        stage: "skip",
                        reason: "not-user-turn",
                        sessionID,
                        rootSessionID: rootSession.id,
                        latestMessageID: latestTurn?.id,
                        fallback: latestTurn?.fallback ?? false,
                        preview: latestTurn?.text ? truncate(latestTurn.text, 120) : null,
                    });
                    return;
                }

                const state = await stateRepository.read();
                if (stateRepository.hasNotification(state, rootSession.id, latestTurn.id)) {
                    await logger.debug({
                        stage: "skip",
                        reason: "already-notified",
                        sessionID,
                        rootSessionID: rootSession.id,
                        latestMessageID: latestTurn.id,
                    });
                    return;
                }

                const preview = buildPreview(latestTurn);
                await publisher.publish({
                    message: preview,
                    sessionTitle: rootSession.title,
                });

                await logger.debug({
                    stage: "notify",
                    sessionID,
                    rootSessionID: rootSession.id,
                    latestMessageID: latestTurn.id,
                    fallback: latestTurn.fallback,
                    preview: truncate(preview, 120),
                });

                await stateRepository.rememberNotification(state, rootSession.id, latestTurn.id);
            }
            catch (error) {
                await logger.debug({
                    stage: "error",
                    sessionID: event.properties.sessionID,
                    error: error instanceof Error ? error.message : String(error),
                });
                console.error("[opencode-ntfy] Failed to evaluate notification state", error);
            }
        },
    };
};
