#!/usr/bin/env python3
from __future__ import annotations

"""Deterministically launch the local team-lead cmux/pi-link layout without relying on the skill prompt."""

import json
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any

ROLES = ("team-lead", "researcher", "coder", "reviewer")
ROLE_MODELS = {
    "team-lead": "openai-codex/gpt-5.4",
    "researcher": "openai-codex/gpt-5.4-mini",
    "coder": "opencode/minimax-m2.5",
    "reviewer": "github-copilot/claude-sonnet-4.6",
}
SPAWN_SETTLE = float(os.environ.get("TEAM_LEAD_SPAWN_SETTLE", "1.0"))
SCREEN_LINES = int(os.environ.get("TEAM_LEAD_SCREEN_LINES", "120"))
ROLE_TITLE_RE = re.compile(
    r"^[^\s@]+@(team-lead|researcher|coder|reviewer)$",
    re.IGNORECASE,
 )
PI_STEADY_MARKERS = (
    "Press Ctrl+C to exit",
    "Alt+Enter",
    "link:",
)


class CommandError(RuntimeError):
    pass


def run_process(argv: list[str]) -> str:
    result = subprocess.run(argv, capture_output=True, text=True)
    if result.returncode != 0:
        raise CommandError(
            f"Command failed ({result.returncode}): {' '.join(argv)}\n"
            f"STDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}"
        )
    return result.stdout.strip()


def run_cmux(args: list[str], *, json_output: bool = False, id_format: str | None = None) -> Any:
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


def get_current_workspace() -> str:
    env_workspace = os.environ.get("CMUX_WORKSPACE_ID")
    if env_workspace:
        return env_workspace
    return parse_workspace_ref(run_cmux(["current-workspace"]))


def get_current_surface() -> str | None:
    return os.environ.get("CMUX_SURFACE_ID")


def get_project_name() -> str:
    return os.path.basename(os.getcwd())


def get_project_dir() -> str:
    return os.getcwd()


def normalize_panel(entry: dict[str, Any]) -> dict[str, Any]:
    return {
        "ref": entry.get("ref") or entry.get("surface") or entry.get("panel"),
        "id": entry.get("id") or entry.get("surface_id") or entry.get("panel_id"),
        "title": entry.get("title"),
        "focused": bool(entry.get("focused", False)),
        "type": entry.get("type"),
    }


def list_panels(workspace: str) -> list[dict[str, Any]]:
    data = run_cmux(["list-panels", "--workspace", workspace], json_output=True, id_format="both")
    items = data.get("surfaces") or data.get("panels") or []
    return [normalize_panel(item) for item in items]


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


def create_cleanup_anchor(workspace: str) -> str:
    output = run_cmux(["new-surface", "--workspace", workspace, "--type", "terminal"])
    fields = parse_key_values(output)
    surface_ref = fields.get("surface")
    if not surface_ref:
        raise CommandError(f"Could not parse cleanup anchor from: {output!r}")
    return surface_ref


def close_surface(workspace: str, surface_id: str) -> None:
    run_cmux(["close-surface", "--workspace", workspace, "--surface", surface_id])


def panel_handles(panel: dict[str, Any]) -> set[str]:
    return {value for value in (panel.get("id"), panel.get("ref")) if isinstance(value, str) and value}


def surface_screen(workspace: str, surface_id: str, *, lines: int = SCREEN_LINES) -> str:
    return run_cmux([
        "read-screen",
        "--workspace",
        workspace,
        "--surface",
        surface_id,
        "--scrollback",
        "--lines",
        str(lines),
    ])


def contains_box_drawing(text: str) -> bool:
    return any(char in text for char in ("╭", "╰", "│", "─", "┌", "└", "┆"))


def surface_runs_pi(screen: str) -> bool:
    visible = "\n".join(screen.splitlines()[-40:])
    lowered = visible.lower()
    has_ui_marker = any(marker.lower() in lowered for marker in PI_STEADY_MARKERS)
    return has_ui_marker and contains_box_drawing(visible)


def surface_has_role_identity(screen: str, expected_title: str) -> bool:
    visible = "\n".join(screen.splitlines()[-60:])
    lowered = visible.lower()
    steady_state_markers = (
        f'joined link as "{expected_title}"'.lower(),
        f"link: {expected_title}".lower(),
    )
    if any(marker in lowered for marker in steady_state_markers):
        return True

    reconnecting_marker = f'reconnecting as "{expected_title}"'.lower()
    return reconnecting_marker in lowered and surface_runs_pi(visible)


def close_matching_panels(
    workspace: str,
    panels: list[dict[str, Any]],
    *,
    exact_titles: set[str],
    close_all_role_tabs: bool = False,
    exclude_handles: set[str] | None = None,
) -> list[dict[str, str]]:
    excluded = exclude_handles or set()
    closed: list[dict[str, str]] = []
    for panel in panels:
        title = panel.get("title")
        handles = panel_handles(panel)
        if not handles.intersection(excluded) and isinstance(title, str):
            should_close = title in exact_titles or (close_all_role_tabs and ROLE_TITLE_RE.match(title))
            if should_close:
                surface_handle = panel.get("id") or panel.get("ref")
                if not isinstance(surface_handle, str) or not surface_handle:
                    continue
                close_surface(workspace, surface_handle)
                closed.append({
                    "title": title,
                    "surface": surface_handle,
                })
    return closed


def discover_existing_roles(
    workspace: str,
    project_name: str,
) -> tuple[dict[str, dict[str, Any]], list[dict[str, Any]]]:
    valid_roles: dict[str, dict[str, Any]] = {}
    stale_panels: list[dict[str, Any]] = []

    for panel in list_panels(workspace):
        title = panel.get("title")
        if not isinstance(title, str):
            continue
        for role in ROLES:
            expected_title = f"{project_name}@{role}"
            if title != expected_title:
                continue
            surface_handle = panel.get("id") or panel.get("ref")
            if not isinstance(surface_handle, str) or not surface_handle:
                stale_panels.append(panel)
                break
            try:
                screen = surface_screen(workspace, surface_handle)
            except CommandError:
                stale_panels.append(panel)
                break
            if surface_runs_pi(screen) and surface_has_role_identity(screen, expected_title):
                if role not in valid_roles:
                    valid_roles[role] = panel
            else:
                stale_panels.append(panel)
            break

    return valid_roles, stale_panels


def spawn_role(role: str, project_name: str, workspace: str, project_dir: str) -> dict[str, Any]:
    helper = Path(__file__).with_name("spawn-agent.py")
    model = ROLE_MODELS[role]
    output = run_process([
        sys.executable,
        str(helper),
        role,
        project_name,
        workspace,
        project_dir,
        model,
    ])
    payload = json.loads(output)
    if payload.get("status") != "ok":
        raise CommandError(f"Spawn helper returned failure for {role}: {output}")
    time.sleep(SPAWN_SETTLE)
    return payload


def launch_team(force: bool = False) -> dict[str, Any]:
    workspace = get_current_workspace()
    project_name = get_project_name()
    project_dir = get_project_dir()
    initiator_surface = get_current_surface()
    desired_titles = {f"{project_name}@{role}" for role in ROLES}

    closed: list[dict[str, str]] = []
    anchor_surface: str | None = None
    initiator_close_requested = False
    try:
        existing_panels = list_panels(workspace)
        exclude_handles = {initiator_surface} if initiator_surface else set()

        if force:
            anchor_surface = create_cleanup_anchor(workspace)
            closed.extend(
                close_matching_panels(
                    workspace,
                    existing_panels,
                    exact_titles=desired_titles,
                    close_all_role_tabs=True,
                    exclude_handles=exclude_handles,
                )
            )
            valid_roles: dict[str, dict[str, Any]] = {}
        else:
            valid_roles, stale_panels = discover_existing_roles(workspace, project_name)
            closed.extend(
                close_matching_panels(
                    workspace,
                    stale_panels,
                    exact_titles=desired_titles,
                    exclude_handles=exclude_handles,
                )
            )

        missing_roles = [role for role in ROLES if role not in valid_roles]
        skipped = [f"{project_name}@{role}" for role in ROLES if role in valid_roles]

        spawned_by_role: dict[str, dict[str, Any]] = {}
        if missing_roles:
            with ThreadPoolExecutor(max_workers=len(missing_roles)) as executor:
                future_to_role = {
                    executor.submit(spawn_role, role, project_name, workspace, project_dir): role
                    for role in missing_roles
                }
                for future in as_completed(future_to_role):
                    role = future_to_role[future]
                    spawned_by_role[role] = future.result()

        spawned = [spawned_by_role[role] for role in missing_roles if role in spawned_by_role]

        keep_handles: set[str] = set()
        for panel in valid_roles.values():
            keep_handles.update(panel_handles(panel))
        for payload in spawned:
            for key in ("surface_uuid", "surface_ref"):
                value = payload.get(key)
                if isinstance(value, str) and value:
                    keep_handles.add(value)

        if initiator_surface and initiator_surface not in keep_handles:
            initiator_close_requested = True

        return {
            "status": "ok",
            "project": project_name,
            "project_dir": project_dir,
            "workspace": workspace,
            "parallel": True,
            "closed": closed,
            "spawned": spawned,
            "skipped": skipped,
            "initiator_surface": initiator_surface,
            "initiator_close_requested": initiator_close_requested,
        }
    finally:
        if anchor_surface is not None:
            try:
                close_surface(workspace, anchor_surface)
            except CommandError:
                pass


def main(argv: list[str]) -> int:
    if len(argv) > 2 or (len(argv) == 2 and argv[1] != "--force"):
        print("Usage: python3 launch-team.py [--force]", file=sys.stderr)
        return 2

    force = len(argv) == 2 and argv[1] == "--force"

    try:
        result = launch_team(force=force)
    except Exception as exc:
        emit({"status": "error", "error": str(exc)}, exit_code=1)

    print(json.dumps(result, ensure_ascii=False))
    sys.stdout.flush()
    if result.get("initiator_close_requested") and isinstance(result.get("initiator_surface"), str):
        try:
            close_surface(result["workspace"], result["initiator_surface"])
        except CommandError:
            pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
