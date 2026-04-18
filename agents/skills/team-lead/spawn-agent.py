#!/usr/bin/env python3
from __future__ import annotations

"""Spawn a linked pi session for one team-lead role inside the current cmux workspace."""

import json
import os
import re
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from typing import Any

CMUX_POLL_INTERVAL = float(os.environ.get("TEAM_LEAD_CMUX_POLL_INTERVAL", "1.0"))
SHELL_READY_TIMEOUT = float(os.environ.get("TEAM_LEAD_SHELL_READY_TIMEOUT", "20"))
PI_READY_TIMEOUT = float(os.environ.get("TEAM_LEAD_PI_READY_TIMEOUT", "90"))
POST_COMMAND_SETTLE = float(os.environ.get("TEAM_LEAD_POST_COMMAND_SETTLE", "1.0"))
ROLE_ASSIGN_TIMEOUT = float(os.environ.get("TEAM_LEAD_ROLE_ASSIGN_TIMEOUT", "60"))
PI_READY_MARKERS = tuple(
    marker.strip()
    for marker in os.environ.get(
        "TEAM_LEAD_PI_READY_MARKERS",
        "Joined link,Link hub started,Press Ctrl+C to exit,Alt+Enter,steering,follow-up",
    ).split(",")
    if marker.strip()
 )
PI_FAILURE_MARKERS = (
    "command not found",
    "no such file or directory",
    "traceback",
    "module not found",
    "cannot find",
    "error:",
)


class CommandError(RuntimeError):
    pass


@dataclass(frozen=True)
class SurfaceTarget:
    workspace: str
    ref: str
    uuid: str


def run_process(argv: list[str]) -> str:
    result = subprocess.run(argv, capture_output=True, text=True)
    if result.returncode != 0:
        raise CommandError(
            f"Command failed ({result.returncode}): {' '.join(argv)}\n"
            f"STDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}"
        )
    return result.stdout.strip()


def run_cmux(
    args: list[str],
    *,
    json_output: bool = False,
    id_format: str | None = None,
 ) -> Any:
    command = ["cmux"]
    if json_output:
        command.append("--json")
    if id_format:
        command.extend(["--id-format", id_format])
    command.extend(args)
    output = run_process(command)
    if not json_output:
        return output
    if not output:
        return {}
    return json.loads(output)


def emit(payload: dict[str, Any], *, exit_code: int) -> None:
    print(json.dumps(payload, ensure_ascii=False))
    raise SystemExit(exit_code)


def parse_workspace_ref(text: str) -> str:
    match = re.search(r"workspace:\d+|[0-9A-Fa-f-]{36}", text)
    if not match:
        raise CommandError(f"Could not parse workspace from: {text!r}")
    return match.group(0)


def get_current_workspace(explicit_workspace: str | None) -> str:
    if explicit_workspace:
        return explicit_workspace
    env_workspace = os.environ.get("CMUX_WORKSPACE_ID")
    if env_workspace:
        return env_workspace
    return parse_workspace_ref(run_cmux(["current-workspace"]))


def normalize_panel(entry: dict[str, Any]) -> dict[str, Any]:
    return {
        "ref": entry.get("ref") or entry.get("surface") or entry.get("panel"),
        "id": entry.get("id") or entry.get("surface_id") or entry.get("panel_id"),
        "title": entry.get("title"),
        "focused": bool(entry.get("focused", False)),
        "type": entry.get("type"),
    }


def list_panels(workspace: str) -> list[dict[str, Any]]:
    data = run_cmux(
        ["list-panels", "--workspace", workspace],
        json_output=True,
        id_format="both",
    )
    items = data.get("surfaces") or data.get("panels") or []
    return [normalize_panel(item) for item in items]


def get_surface_health(workspace: str) -> list[dict[str, Any]]:
    data = run_cmux(["surface-health", "--workspace", workspace], json_output=True)
    return data.get("surfaces") or data.get("panels") or []


def surface_exists(surface: SurfaceTarget) -> bool:
    for item in list_panels(surface.workspace):
        item_ref = item.get("ref") or item.get("surface") or item.get("panel")
        item_id = item.get("id") or item.get("surface_id") or item.get("panel_id")
        if item_ref == surface.ref or item_id == surface.uuid:
            return True
    return False


def parse_key_values(output: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for token in output.split():
        if ":" in token:
            key, value = token.split(":", 1)
            if key and value:
                fields[key] = f"{key}:{value}"
        elif "=" in token:
            key, value = token.split("=", 1)
            if key and value:
                fields[key] = value
    return fields


def create_surface(workspace: str) -> SurfaceTarget:
    before = list_panels(workspace)
    before_ids = {item["id"] for item in before if item.get("id")}
    before_refs = {item["ref"] for item in before if item.get("ref")}

    created_output = run_cmux(["new-surface", "--workspace", workspace, "--type", "terminal"])
    fields = parse_key_values(created_output)
    created_ref = fields.get("surface")

    after = list_panels(workspace)
    created_panel: dict[str, Any] | None = None
    if created_ref:
        created_panel = next((item for item in after if item.get("ref") == created_ref), None)
        if created_panel is None:
            raise CommandError(
                "cmux reported a created surface ref but it was not visible in list-panels. "
                f"new-surface output={created_output!r}"
            )
    if created_panel is None:
        new_panels = [
            item
            for item in after
            if item.get("id") not in before_ids and item.get("ref") not in before_refs
        ]
        if len(new_panels) != 1:
            raise CommandError(
                "Could not uniquely identify the newly created surface. "
                f"new-surface output={created_output!r}"
            )
        created_panel = new_panels[0]

    surface_uuid = created_panel.get("id")
    surface_ref = created_panel.get("ref")
    if not surface_uuid or not surface_ref:
        raise CommandError(f"Surface IDs are incomplete: {created_panel!r}")
    return SurfaceTarget(workspace=workspace, ref=surface_ref, uuid=surface_uuid)


def close_surface(surface: SurfaceTarget) -> None:
    try:
        run_cmux([
            "close-surface",
            "--workspace",
            surface.workspace,
            "--surface",
            surface.uuid,
        ])
    except CommandError:
        pass


def rename_surface(surface: SurfaceTarget, title: str) -> None:
    run_cmux([
        "rename-tab",
        "--workspace",
        surface.workspace,
        "--surface",
        surface.uuid,
        title,
    ])


def read_screen(surface: SurfaceTarget, *, lines: int = 200) -> str:
    return run_cmux([
        "read-screen",
        "--workspace",
        surface.workspace,
        "--surface",
        surface.uuid,
        "--scrollback",
        "--lines",
        str(lines),
    ])


def send_text(surface: SurfaceTarget, text: str) -> None:
    run_cmux([
        "send",
        "--workspace",
        surface.workspace,
        "--surface",
        surface.uuid,
        text,
    ])
    run_cmux([
        "send-key",
        "--workspace",
        surface.workspace,
        "--surface",
        surface.uuid,
        "Enter",
    ])


def surface_is_ready(surface: SurfaceTarget) -> bool:
    for item in get_surface_health(surface.workspace):
        item_ref = item.get("ref") or item.get("surface") or item.get("panel")
        item_id = item.get("id") or item.get("surface_id") or item.get("panel_id")
        if item_ref == surface.ref or item_id == surface.uuid:
            return True
    return surface_exists(surface)


def wait_for_shell_ready(surface: SurfaceTarget) -> str:
    deadline = time.time() + SHELL_READY_TIMEOUT
    consecutive_reads = 0
    last_screen = ""
    while time.time() < deadline:
        if not surface_is_ready(surface):
            time.sleep(CMUX_POLL_INTERVAL)
            continue
        try:
            last_screen = read_screen(surface)
            consecutive_reads += 1
        except CommandError:
            consecutive_reads = 0
            time.sleep(CMUX_POLL_INTERVAL)
            continue
        if consecutive_reads >= 2:
            return last_screen
        time.sleep(CMUX_POLL_INTERVAL)
    raise CommandError(
        f"Surface {surface.ref} ({surface.uuid}) did not become ready within {SHELL_READY_TIMEOUT}s"
    )


def contains_any_marker(text: str, markers: tuple[str, ...]) -> bool:
    lowered = text.lower()
    return any(marker.lower() in lowered for marker in markers)


def contains_box_drawing(text: str) -> bool:
    return any(char in text for char in ("╭", "╰", "│", "─", "┌", "└", "┆"))


def wait_for_pi_ready(surface: SurfaceTarget, shell_snapshot: str) -> str:
    deadline = time.time() + PI_READY_TIMEOUT
    last_screen = shell_snapshot
    stable_reads = 0
    shell_snapshot = shell_snapshot.strip()
    while time.time() < deadline:
        screen = read_screen(surface)
        normalized = screen.strip()
        if contains_any_marker(normalized, PI_FAILURE_MARKERS):
            raise CommandError(
                "Pi failed to start cleanly or the command landed in the shell. "
                f"Screen:\n{screen}"
            )
        if normalized and normalized == last_screen.strip():
            stable_reads += 1
        else:
            stable_reads = 0
        last_screen = screen

        changed_from_shell = bool(normalized) and normalized != shell_snapshot
        if changed_from_shell and contains_any_marker(normalized, PI_READY_MARKERS):
            return screen
        if changed_from_shell and contains_box_drawing(normalized) and stable_reads >= 1:
            return screen

        time.sleep(CMUX_POLL_INTERVAL)

    raise CommandError(
        f"Pi did not look ready on {surface.ref} ({surface.uuid}) within {PI_READY_TIMEOUT}s"
    )


def maybe_connect_link(surface: SurfaceTarget) -> bool:
    screen = read_screen(surface)
    lowered = screen.lower()
    if "not connected" in lowered or "disconnected" in lowered:
        send_text(surface, "/link-connect")
        time.sleep(POST_COMMAND_SETTLE)
        return True
    return False


def role_name_seen(screen: str, title: str) -> bool:
    lowered = screen.lower()
    return (
        f'joined link as "{title}"'.lower() in lowered
        or f"link: {title}".lower() in lowered
    )


def wait_for_role_name(surface: SurfaceTarget, title: str) -> str:
    deadline = time.time() + ROLE_ASSIGN_TIMEOUT
    last_screen = ""
    while time.time() < deadline:
        last_screen = read_screen(surface)
        if role_name_seen(last_screen, title):
            return last_screen
        time.sleep(CMUX_POLL_INTERVAL)
    raise CommandError(
        f"Pi started on {surface.ref} ({surface.uuid}) but role {title!r} never appeared within {ROLE_ASSIGN_TIMEOUT}s"
    )

def spawn_agent(
    role: str,
    project_name: str,
    explicit_workspace: str | None,
    project_dir: str,
    model: str | None,
 ) -> dict[str, Any]:
    title = f"{project_name}@{role}"
    workspace = get_current_workspace(explicit_workspace)
    surface = create_surface(workspace)

    try:
        rename_surface(surface, title)
        wait_for_shell_ready(surface)
        send_text(surface, f"cd {shlex.quote(project_dir)}")
        time.sleep(POST_COMMAND_SETTLE)
        pi_command = "pi --link" if not model else f"pi --link --model {shlex.quote(model)}"
        send_text(surface, pi_command)
        wait_for_pi_ready(surface, read_screen(surface))
        maybe_connect_link(surface)
        send_text(surface, f"/link-name {title}")
        time.sleep(POST_COMMAND_SETTLE)
        pi_screen = wait_for_role_name(surface, title)
        rename_surface(surface, title)
    except Exception:
        close_surface(surface)
        raise

    return {
        "status": "ok",
        "role": role,
        "title": title,
        "workspace": workspace,
        "project_dir": project_dir,
        "model": model,
        "surface_ref": surface.ref,
        "surface_uuid": surface.uuid,
        "pi_ready_screen_excerpt": "\n".join(pi_screen.splitlines()[-20:]),
    }


def main(argv: list[str]) -> int:
    if len(argv) < 2 or len(argv) > 6:
        print(
            "Usage: python3 spawn-agent.py <role> <project-name> [workspace-id] [project-dir] [model]",
            file=sys.stderr,
        )
        return 2

    role = argv[1]
    project_name = argv[2] if len(argv) >= 3 else os.path.basename(os.getcwd())
    explicit_workspace = argv[3] if len(argv) >= 4 else None
    project_dir = argv[4] if len(argv) >= 5 else os.getcwd()
    model = argv[5] if len(argv) == 6 else None

    try:
        result = spawn_agent(role, project_name, explicit_workspace, project_dir, model)
    except Exception as exc:
        emit(
            {
                "status": "error",
                "role": role,
                "project": project_name,
                "project_dir": project_dir,
                "workspace": explicit_workspace or os.environ.get("CMUX_WORKSPACE_ID"),
                "model": model,
                "error": str(exc),
            },
            exit_code=1,
        )

    emit(result, exit_code=0)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))