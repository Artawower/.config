import { appendFile, mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const DEFAULT_SERVER = "https://ntfy.sh";
const DEFAULT_PRIORITY = "high";
const DEFAULT_TAGS = ["computer"];
const DEFAULT_SETTLE_MS = 4000;
const MAX_SETTLE_MS = 30000;
const STALE_TURN_MS = 5 * 60 * 1000;
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

const extensionDir = path.dirname(fileURLToPath(import.meta.url));
const STATE_FILE = path.join(extensionDir, "pi-ntfy-state.json");
const DEBUG_FILE = path.join(extensionDir, "pi-ntfy-debug.log");

type ContentBlock = { type?: string; text?: string };
type NotificationState = {
	notifications?: Record<string, { fingerprint: string; time: number }>;
};
type TurnSnapshot = {
	text: string;
	endedAt: number;
	notifyCandidate: boolean;
};

function trimTrailingSlash(value: string): string {
	return value.replace(/\/+$/, "");
}

function normalizeTags(value?: string): string[] {
	if (!value) return DEFAULT_TAGS;
	const tags = value.split(",").map((tag) => tag.trim()).filter(Boolean);
	return tags.length > 0 ? tags : DEFAULT_TAGS;
}

function getEnvValue(name: string): string | undefined {
	return process.env[`PI_NTFY_${name}`]?.trim() || process.env[`OPENCODE_NTFY_${name}`]?.trim();
}

function clampSettleMs(value: number): number {
	if (!Number.isFinite(value) || value < 0) return DEFAULT_SETTLE_MS;
	return Math.min(Math.round(value), MAX_SETTLE_MS);
}

function truncate(value: string, maxLength = 180): string {
	if (value.length <= maxLength) return value;
	return `${value.slice(0, maxLength - 1)}…`;
}

function sanitizeHeaderValue(value: string): string {
	return value.replace(/[\r\n]+/g, " ").replace(/[^\x20-\x7E]/g, "").replace(/\s+/g, " ").trim();
}

function extractText(content: unknown): string {
	if (typeof content === "string") return content.trim();
	if (!Array.isArray(content)) return "";

	return content
		.filter((part): part is ContentBlock => Boolean(part) && typeof part === "object")
		.filter((part) => part.type === "text" && typeof part.text === "string")
		.map((part) => part.text?.trim() ?? "")
		.filter(Boolean)
		.join("\n\n")
		.trim();
}

function projectNameFromCwd(cwd: string): string {
	const base = path.basename(cwd);
	return base || "workspace";
}

function getSessionKey(sessionFile?: string | null): string {
	return sessionFile ?? "ephemeral";
}

function isUserAttentionText(text: string): boolean {
	const normalized = text.trim();
	if (!normalized) return false;
	if (USER_TURN_PATTERNS.some((pattern) => pattern.test(normalized))) return true;
	if (STATUS_ONLY_PATTERNS.some((pattern) => pattern.test(normalized))) return false;
	return false;
}

function buildFingerprint(text: string): string {
	return text;
}

function isFreshTurn(turn: TurnSnapshot | null): boolean {
	return Boolean(turn && Date.now() - turn.endedAt <= STALE_TURN_MS);
}

async function ensureParentDir(filePath: string): Promise<void> {
	await mkdir(path.dirname(filePath), { recursive: true });
}

async function readState(): Promise<NotificationState> {
	try {
		return JSON.parse(await readFile(STATE_FILE, "utf8")) as NotificationState;
	} catch {
		return {};
	}
}

async function writeState(state: NotificationState): Promise<void> {
	await ensureParentDir(STATE_FILE);
	await writeFile(STATE_FILE, `${JSON.stringify(state, null, 2)}\n`, "utf8");
}

async function debugLog(enabled: boolean, entry: Record<string, unknown>): Promise<void> {
	if (!enabled) return;
	await ensureParentDir(DEBUG_FILE);
	await appendFile(DEBUG_FILE, `${JSON.stringify({ time: new Date().toISOString(), ...entry })}\n`, "utf8");
}

async function publishNotification(config: {
	server: string;
	topic: string;
	token?: string;
	priority: string;
	tags: string[];
	click?: string;
	projectName: string;
}, payload: { message: string; title?: string }): Promise<void> {
	const headers: Record<string, string> = {
		Title: sanitizeHeaderValue(`Pi · ${config.projectName}`) || "Pi",
		Priority: config.priority,
		Tags: sanitizeHeaderValue(config.tags.join(",")),
	};

	if (config.token) headers.Authorization = `Token ${config.token}`;
	if (config.click) headers.Click = sanitizeHeaderValue(config.click);

	const body = payload.title
		? `[${config.projectName}] ${payload.title}\n\n${payload.message}`
		: payload.message;
	const response = await fetch(`${config.server}/${config.topic}`, {
		method: "POST",
		headers,
		body,
	});

	if (!response.ok) {
		throw new Error(`ntfy publish failed (${response.status}): ${await response.text()}`);
	}
}

export default function (pi: ExtensionAPI) {
	let agentActive = false;
	let latestTurn: TurnSnapshot | null = null;

	const config = {
		topic: getEnvValue("TOPIC"),
		server: trimTrailingSlash(getEnvValue("SERVER") || DEFAULT_SERVER),
		token: getEnvValue("TOKEN"),
		priority: getEnvValue("PRIORITY") || DEFAULT_PRIORITY,
		tags: normalizeTags(getEnvValue("TAGS")),
		click: getEnvValue("CLICK"),
		settleMs: clampSettleMs(Number(getEnvValue("SETTLE_MS") || DEFAULT_SETTLE_MS)),
		debug: getEnvValue("DEBUG") === "true",
		projectName: projectNameFromCwd(process.cwd()),
	};

	async function maybeNotify(ctx: Parameters<Parameters<typeof pi.on>[1]>[1], reason: "agent_end" | "session_shutdown") {
		if (!config.topic) {
			await debugLog(config.debug, { stage: "skip", reason: "missing-topic", trigger: reason });
			return;
		}

		await new Promise((resolve) => setTimeout(resolve, config.settleMs));
		if (agentActive) {
			await debugLog(config.debug, { stage: "skip", reason: "agent-still-active", trigger: reason });
			return;
		}

		if (!latestTurn) {
			await debugLog(config.debug, { stage: "skip", reason: "no-turn-snapshot", trigger: reason });
			return;
		}

		if (!isFreshTurn(latestTurn)) {
			await debugLog(config.debug, { stage: "skip", reason: "stale-turn", trigger: reason, endedAt: latestTurn.endedAt });
			return;
		}

		if (!latestTurn.notifyCandidate) {
			await debugLog(config.debug, { stage: "skip", reason: "not-user-attention", trigger: reason, preview: truncate(latestTurn.text, 120) });
			return;
		}

		const sessionKey = getSessionKey(ctx.sessionManager.getSessionFile());
		const fingerprint = buildFingerprint(latestTurn.text);
		const state = await readState();
		if (state.notifications?.[sessionKey]?.fingerprint === fingerprint) {
			await debugLog(config.debug, { stage: "skip", reason: "already-notified", trigger: reason, sessionKey });
			return;
		}

		const body = truncate(latestTurn.text);
		await publishNotification(config, {
			message: body,
			title: ctx.sessionManager.getSessionFile() ? path.basename(ctx.sessionManager.getSessionFile() as string) : undefined,
		});

		await writeState({
			...state,
			notifications: {
				...(state.notifications ?? {}),
				[sessionKey]: { fingerprint, time: Date.now() },
			},
		});
		await debugLog(config.debug, {
			stage: "notify",
			trigger: reason,
			sessionKey,
			preview: truncate(body, 120),
			endedAt: latestTurn.endedAt,
		});
	}

	pi.on("agent_start", async () => {
		agentActive = true;
	});

	pi.on("turn_end", async (event) => {
		const text = extractText(event.message?.content);
		latestTurn = {
			text,
			endedAt: Date.now(),
			notifyCandidate: isUserAttentionText(text),
		};
	});

	pi.on("agent_end", async (_event, ctx) => {
		agentActive = false;
		await maybeNotify(ctx, "agent_end");
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		agentActive = false;
		await maybeNotify(ctx, "session_shutdown");
	});
}
