#!/usr/bin/env python3
from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import os
import re
import shlex
import subprocess
import sys
import time
import tomllib
from dataclasses import dataclass
from pathlib import Path
from typing import Any

SHELL_READY_TIMEOUT = float(os.environ.get("LAYOUT_SHELL_READY_TIMEOUT", "20"))
POLL_INTERVAL = float(os.environ.get("LAYOUT_POLL_INTERVAL", "1.0"))


class CommandError(RuntimeError):
    pass


@dataclass(frozen=True)
class SurfaceTarget:
    workspace: str
    ref: str
    uuid: str
    pane_ref: str | None
    pane_uuid: str | None


@dataclass(frozen=True)
class PaneTarget:
    workspace: str
    ref: str
    uuid: str
    selected_surface_ref: str | None
    selected_surface_uuid: str | None


@dataclass(frozen=True)
class PiLaunch:
    role: str


@dataclass(frozen=True)
class TabSpec:
    name: str
    command: str | None
    pi: PiLaunch | None
    pane_id: str
    split_from: str | None
    split_direction: str | None


@dataclass(frozen=True)
class Preset:
    path: Path
    id: str
    name: str
    description: str | None
    tabs: tuple[TabSpec, ...]


@dataclass(frozen=True)
class RenderedTab:
    pane_id: str
    order: int
    title: str
    startup_command: str | None


def run_process(argv: list[str], *, input_text: str | None = None) -> str:
    result = subprocess.run(argv, input=input_text, capture_output=True, text=True)
    if result.returncode != 0:
        raise CommandError(
            f"Command failed ({result.returncode}): {' '.join(argv)}\n"
            f"STDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}"
        )
    return result.stdout.strip()


def run_cmux(
    args: list[str], *, json_output: bool = False, id_format: str | None = None
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


def normalize_panel(entry: dict[str, Any]) -> dict[str, Any]:
    return {
        "ref": entry.get("ref") or entry.get("surface") or entry.get("panel"),
        "id": entry.get("id") or entry.get("surface_id") or entry.get("panel_id"),
        "title": entry.get("title"),
        "focused": bool(entry.get("focused", False)),
        "type": entry.get("type"),
        "pane_ref": entry.get("pane_ref"),
        "pane_id": entry.get("pane_id"),
    }


def normalize_pane(entry: dict[str, Any]) -> dict[str, Any]:
    return {
        "ref": entry.get("ref") or entry.get("pane"),
        "id": entry.get("id") or entry.get("pane_id"),
        "focused": bool(entry.get("focused", False)),
        "selected_surface_ref": entry.get("selected_surface_ref"),
        "selected_surface_id": entry.get("selected_surface_id"),
    }


def list_panels(workspace: str) -> list[dict[str, Any]]:
    data = run_cmux(
        ["list-panels", "--workspace", workspace], json_output=True, id_format="both"
    )
    items = data.get("surfaces") or data.get("panels") or []
    return [normalize_panel(item) for item in items]


def list_panes(workspace: str) -> list[dict[str, Any]]:
    data = run_cmux(
        ["list-panes", "--workspace", workspace], json_output=True, id_format="both"
    )
    items = data.get("panes") or []
    return [normalize_pane(item) for item in items]


def get_surface_health(workspace: str) -> list[dict[str, Any]]:
    data = run_cmux(["surface-health", "--workspace", workspace], json_output=True)
    return data.get("surfaces") or data.get("panels") or []


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


def get_root_pane(workspace: str) -> PaneTarget:
    panes = list_panes(workspace)
    if not panes:
        raise CommandError(f"No panes found in workspace {workspace}")
    pane = next((item for item in panes if item.get("focused")), panes[0])
    pane_uuid = pane.get("id")
    pane_ref = pane.get("ref")
    if not pane_uuid or not pane_ref:
        raise CommandError(f"Pane identifiers are incomplete: {pane!r}")
    return PaneTarget(
        workspace=workspace,
        ref=pane_ref,
        uuid=pane_uuid,
        selected_surface_ref=None,
        selected_surface_uuid=None,
    )


def create_split(workspace: str, parent: PaneTarget, direction: str) -> PaneTarget:
    before = list_panes(workspace)
    before_ids = {item["id"] for item in before if item.get("id")}
    before_refs = {item["ref"] for item in before if item.get("ref")}

    output = run_cmux(
        ["new-split", direction, "--workspace", workspace, "--pane", parent.uuid]
    )
    fields = parse_key_values(output)
    created_ref = fields.get("pane")

    after = list_panes(workspace)
    created_pane: dict[str, Any] | None = None
    if created_ref:
        created_pane = next(
            (item for item in after if item.get("ref") == created_ref), None
        )
        if created_pane is None:
            raise CommandError(
                "cmux reported a created pane ref but it was not visible in list-panes. "
                f"new-split output={output!r}"
            )
    if created_pane is None:
        new_panes = [
            item
            for item in after
            if item.get("id") not in before_ids and item.get("ref") not in before_refs
        ]
        if len(new_panes) != 1:
            raise CommandError(
                "Could not uniquely identify the newly created pane. "
                f"new-split output={output!r}"
            )
        created_pane = new_panes[0]

    pane_uuid = created_pane.get("id")
    pane_ref = created_pane.get("ref")
    if not pane_uuid or not pane_ref:
        raise CommandError(f"Pane IDs are incomplete: {created_pane!r}")
    return PaneTarget(
        workspace=workspace,
        ref=pane_ref,
        uuid=pane_uuid,
        selected_surface_ref=created_pane.get("selected_surface_ref"),
        selected_surface_uuid=created_pane.get("selected_surface_id"),
    )


def create_surface(workspace: str, pane: PaneTarget) -> SurfaceTarget:
    before = list_panels(workspace)
    before_ids = {item["id"] for item in before if item.get("id")}
    before_refs = {item["ref"] for item in before if item.get("ref")}

    created_output = run_cmux(
        [
            "new-surface",
            "--workspace",
            workspace,
            "--pane",
            pane.uuid,
            "--type",
            "terminal",
        ]
    )
    fields = parse_key_values(created_output)
    created_ref = fields.get("surface")

    after = list_panels(workspace)
    created_panel: dict[str, Any] | None = None
    if created_ref:
        created_panel = next(
            (item for item in after if item.get("ref") == created_ref), None
        )
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
    return SurfaceTarget(
        workspace=workspace,
        ref=surface_ref,
        uuid=surface_uuid,
        pane_ref=created_panel.get("pane_ref"),
        pane_uuid=created_panel.get("pane_id"),
    )


def rename_surface(surface: SurfaceTarget, title: str) -> None:
    run_cmux(
        [
            "rename-tab",
            "--workspace",
            surface.workspace,
            "--surface",
            surface.uuid,
            title,
        ]
    )


def read_screen(surface: SurfaceTarget, *, lines: int = 120) -> str:
    return run_cmux(
        [
            "read-screen",
            "--workspace",
            surface.workspace,
            "--surface",
            surface.uuid,
            "--scrollback",
            "--lines",
            str(lines),
        ]
    )


def send_text(surface: SurfaceTarget, text: str) -> None:
    run_cmux(
        ["send", "--workspace", surface.workspace, "--surface", surface.uuid, text]
    )
    run_cmux(
        [
            "send-key",
            "--workspace",
            surface.workspace,
            "--surface",
            surface.uuid,
            "Enter",
        ]
    )


def surface_is_ready(surface: SurfaceTarget) -> bool:
    for item in get_surface_health(surface.workspace):
        item_ref = item.get("ref") or item.get("surface") or item.get("panel")
        item_id = item.get("id") or item.get("surface_id") or item.get("panel_id")
        if item_ref == surface.ref or item_id == surface.uuid:
            return bool(item.get("in_window"))
    return False


def wait_for_shell_ready(surface: SurfaceTarget) -> None:
    deadline = time.time() + SHELL_READY_TIMEOUT
    consecutive_reads = 0
    while time.time() < deadline:
        if not surface_is_ready(surface):
            time.sleep(POLL_INTERVAL)
            continue
        try:
            read_screen(surface)
            consecutive_reads += 1
        except CommandError:
            consecutive_reads = 0
            time.sleep(POLL_INTERVAL)
            continue
        if consecutive_reads >= 2:
            return
        time.sleep(POLL_INTERVAL)
    raise CommandError(
        f"Surface {surface.ref} ({surface.uuid}) did not become ready within {SHELL_READY_TIMEOUT}s"
    )


def render_template(text: str, *, dir_name: str, cwd: str) -> str:
    return text.format(dir=dir_name, cwd=cwd)


def build_pi_command(pi: PiLaunch, *, dir_name: str, cwd: str) -> str:
    link_name = f"{dir_name}@{pi.role}"
    return f"pi-link {shlex.quote(link_name)}"


def parse_pi_launch(
    source_path: Path, layout_id: str, tab_index: int, entry: dict[str, Any]
) -> PiLaunch:
    role = entry.get("role")
    if not isinstance(role, str) or not role.strip():
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} has invalid pi.role; expected a non-empty string"
        )
    return PiLaunch(role=role.strip())


def parse_tab_entry(
    source_path: Path, layout_id: str, tab_index: int, tab_entry: dict[str, Any]
) -> TabSpec:
    tab_name = tab_entry.get("name")
    if not isinstance(tab_name, str) or not tab_name.strip():
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} is missing a non-empty 'name'"
        )

    pane_id = tab_entry.get("pane") or "root"
    if not isinstance(pane_id, str) or not pane_id.strip():
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} has an invalid 'pane'"
        )
    pane_id = pane_id.strip()

    split_from = tab_entry.get("split_from")
    if split_from is not None and (
        not isinstance(split_from, str) or not split_from.strip()
    ):
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} has an invalid 'split_from'"
        )
    split_from = split_from.strip() if isinstance(split_from, str) else None

    split_direction = tab_entry.get("split")
    if split_direction is not None and split_direction not in {
        "left",
        "right",
        "up",
        "down",
    }:
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} has invalid split direction {split_direction!r}"
        )

    command = tab_entry.get("command")
    if command is not None and (not isinstance(command, str) or not command.strip()):
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} has an invalid 'command'"
        )

    pi_entry = tab_entry.get("pi")
    pi: PiLaunch | None = None
    if pi_entry is not None:
        if not isinstance(pi_entry, dict):
            raise CommandError(
                f"{source_path.name} layout {layout_id!r} tab #{tab_index} has an invalid [pi] table"
            )
        pi = parse_pi_launch(source_path, layout_id, tab_index, pi_entry)

    if command is not None and pi is not None:
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} tab #{tab_index} cannot define both command and pi"
        )

    return TabSpec(
        name=tab_name.strip(),
        command=command.strip() if isinstance(command, str) else None,
        pi=pi,
        pane_id=pane_id,
        split_from=split_from,
        split_direction=split_direction,
    )


def validate_tab_panes(source_path: Path, layout_id: str, tabs: list[TabSpec]) -> None:
    pane_defs: dict[str, tuple[str | None, str | None]] = {}
    pane_order: list[str] = []
    for tab in tabs:
        definition = (tab.split_from, tab.split_direction)
        if tab.pane_id in pane_defs:
            if pane_defs[tab.pane_id] != definition:
                raise CommandError(
                    f"{source_path.name} layout {layout_id!r} defines pane {tab.pane_id!r} with conflicting split settings"
                )
        else:
            pane_defs[tab.pane_id] = definition
            pane_order.append(tab.pane_id)

    root_candidates = [
        pane_id
        for pane_id, definition in pane_defs.items()
        if definition == (None, None)
    ]
    if len(root_candidates) != 1:
        raise CommandError(
            f"{source_path.name} layout {layout_id!r} must have exactly one root pane (tabs without split/split_from)"
        )

    for pane_id in pane_order:
        split_from, split_direction = pane_defs[pane_id]
        if split_from is None and split_direction is None:
            continue
        if split_from is None or split_direction is None:
            raise CommandError(
                f"{source_path.name} layout {layout_id!r} pane {pane_id!r} must define both split_from and split"
            )
        if split_from not in pane_defs:
            raise CommandError(
                f"{source_path.name} layout {layout_id!r} pane {pane_id!r} references unknown split_from {split_from!r}"
            )
        if pane_order.index(split_from) >= pane_order.index(pane_id):
            raise CommandError(
                f"{source_path.name} layout {layout_id!r} pane {pane_id!r} must appear after split_from pane {split_from!r}"
            )


def parse_preset_entry(source_path: Path, entry: dict[str, Any], index: int) -> Preset:
    preset_id = entry.get("id")
    if not isinstance(preset_id, str) or not preset_id.strip():
        raise CommandError(
            f"{source_path.name} layout #{index} is missing a non-empty 'id'"
        )
    preset_id = preset_id.strip()

    name = entry.get("name")
    if not isinstance(name, str) or not name.strip():
        raise CommandError(
            f"{source_path.name} layout {preset_id!r} is missing a non-empty 'name'"
        )

    description = entry.get("description")
    if description is not None and not isinstance(description, str):
        raise CommandError(
            f"{source_path.name} layout {preset_id!r} has a non-string 'description'"
        )

    tabs_data = entry.get("tabs")
    if not isinstance(tabs_data, list) or not tabs_data:
        raise CommandError(
            f"{source_path.name} layout {preset_id!r} must define a non-empty tabs array"
        )

    tabs: list[TabSpec] = []
    for tab_index, tab_entry in enumerate(tabs_data, start=1):
        if not isinstance(tab_entry, dict):
            raise CommandError(
                f"{source_path.name} layout {preset_id!r} tab #{tab_index} must be a table"
            )
        tabs.append(parse_tab_entry(source_path, preset_id, tab_index, tab_entry))

    validate_tab_panes(source_path, preset_id, tabs)

    return Preset(
        path=source_path,
        id=preset_id,
        name=name.strip(),
        description=description.strip() if isinstance(description, str) else None,
        tabs=tuple(tabs),
    )


def discover_presets(preset_dir: Path) -> list[Preset]:
    catalog_path = preset_dir / "layouts.toml"
    if not catalog_path.exists():
        raise CommandError(f"Preset catalog not found: {catalog_path}")

    with catalog_path.open("rb") as fh:
        data = tomllib.load(fh)

    layouts = data.get("layouts")
    if not isinstance(layouts, list) or not layouts:
        raise CommandError(
            f"{catalog_path.name} must define a non-empty [[layouts]] array"
        )

    presets = [
        parse_preset_entry(catalog_path, entry, index)
        for index, entry in enumerate(layouts, start=1)
    ]
    seen_ids: set[str] = set()
    for preset in presets:
        if preset.id in seen_ids:
            raise CommandError(
                f"Duplicate layout id in {catalog_path.name}: {preset.id}"
            )
        seen_ids.add(preset.id)
    return presets


def choose_preset_with_fzf(presets: list[Preset]) -> Preset:
    fzf_path = shutil_which("fzf")
    if not fzf_path:
        raise CommandError("fzf is required when no preset is specified")

    lines = []
    lookup: dict[str, Preset] = {}
    for preset in presets:
        desc = preset.description or ""
        line = f"{preset.id}\t{preset.name}\t{desc}"
        lines.append(line)
        lookup[line] = preset

    selected = run_process(
        [fzf_path, "--with-nth=1,2,3", "--delimiter=\t", "--prompt", "layout preset> "],
        input_text="\n".join(lines),
    )
    preset = lookup.get(selected)
    if preset is None:
        raise CommandError("fzf returned an unknown preset selection")
    return preset


def resolve_preset(presets: list[Preset], query: str | None) -> Preset:
    if query is None:
        return choose_preset_with_fzf(presets)

    by_id = next((preset for preset in presets if preset.id == query), None)
    if by_id is not None:
        return by_id

    raise CommandError(f"Unknown preset: {query}")


def create_tab_surface(workspace: str, pane: PaneTarget, title: str) -> SurfaceTarget:
    surface = create_surface(workspace, pane)
    rename_surface(surface, title)
    return surface


def reuse_selected_surface(pane: PaneTarget, title: str) -> SurfaceTarget:
    if not pane.selected_surface_ref or not pane.selected_surface_uuid:
        raise CommandError(f"Pane {pane.ref} has no selected surface to reuse")
    surface = SurfaceTarget(
        workspace=pane.workspace,
        ref=pane.selected_surface_ref,
        uuid=pane.selected_surface_uuid,
        pane_ref=pane.ref,
        pane_uuid=pane.uuid,
    )
    rename_surface(surface, title)
    return surface


def initialize_tab(
    surface: SurfaceTarget, startup_command: str | None, cwd: str
) -> None:
    wait_for_shell_ready(surface)
    send_text(surface, f"cd {shlex.quote(cwd)}")
    if startup_command:
        send_text(surface, startup_command)


def render_preset(preset: Preset, cwd: str) -> list[RenderedTab]:
    dir_name = os.path.basename(cwd)
    rendered_tabs: list[RenderedTab] = []
    for index, tab in enumerate(preset.tabs):
        if tab.command is not None:
            startup_command = render_template(tab.command, dir_name=dir_name, cwd=cwd)
        elif tab.pi is not None:
            startup_command = build_pi_command(tab.pi, dir_name=dir_name, cwd=cwd)
        else:
            startup_command = None
        rendered_tabs.append(
            RenderedTab(
                pane_id=tab.pane_id,
                order=index,
                title=render_template(tab.name, dir_name=dir_name, cwd=cwd),
                startup_command=startup_command,
            )
        )
    return rendered_tabs


def launch_preset(preset: Preset) -> dict[str, Any]:
    workspace = get_current_workspace()
    cwd = os.getcwd()
    rendered_tabs = render_preset(preset, cwd)

    pane_targets: dict[str, PaneTarget] = {}
    root_pane = get_root_pane(workspace)

    pane_sequence: list[TabSpec] = []
    seen_panes: set[str] = set()
    for tab in preset.tabs:
        if tab.pane_id not in seen_panes:
            pane_sequence.append(tab)
            seen_panes.add(tab.pane_id)

    for tab in pane_sequence:
        if tab.split_from is None:
            pane_targets[tab.pane_id] = root_pane
        else:
            parent = pane_targets.get(tab.split_from)
            if parent is None:
                raise CommandError(
                    f"Pane {tab.pane_id!r} references split_from {tab.split_from!r} before it exists"
                )
            pane_targets[tab.pane_id] = create_split(
                workspace, parent, tab.split_direction or "right"
            )

    created_tabs: list[tuple[RenderedTab, SurfaceTarget]] = []
    reused_selected_by_pane: set[str] = set()
    for tab in reversed(rendered_tabs):
        pane_target = pane_targets[tab.pane_id]
        if (
            tab.pane_id != "root"
            and tab.pane_id not in reused_selected_by_pane
            and pane_target.selected_surface_uuid
        ):
            created_tabs.append((tab, reuse_selected_surface(pane_target, tab.title)))
            reused_selected_by_pane.add(tab.pane_id)
        else:
            created_tabs.append(
                (tab, create_tab_surface(workspace, pane_target, tab.title))
            )

    initialization_errors: list[str] = []
    with ThreadPoolExecutor(max_workers=len(created_tabs) or 1) as executor:
        future_to_rendered = {
            executor.submit(
                initialize_tab, surface, rendered.startup_command, cwd
            ): rendered
            for rendered, surface in created_tabs
        }
        for future in as_completed(future_to_rendered):
            rendered = future_to_rendered[future]
            try:
                future.result()
            except Exception as exc:
                initialization_errors.append(f"{rendered.title}: {exc}")

    if initialization_errors:
        raise CommandError("; ".join(initialization_errors))

    launched = [
        {
            "pane_id": rendered.pane_id,
            "title": rendered.title,
            "startup_command": rendered.startup_command,
            "surface_ref": surface.ref,
            "surface_uuid": surface.uuid,
            "pane_ref": surface.pane_ref,
            "pane_uuid": surface.pane_uuid,
        }
        for rendered, surface in sorted(created_tabs, key=lambda item: item[0].order)
    ]

    panes = [
        {
            "id": pane_id,
            "pane_ref": pane_targets[pane_id].ref,
            "pane_uuid": pane_targets[pane_id].uuid,
        }
        for pane_id in pane_targets
    ]

    return {
        "status": "ok",
        "preset": preset.id,
        "name": preset.name,
        "description": preset.description,
        "workspace": workspace,
        "cwd": cwd,
        "parallel": True,
        "panes": panes,
        "launched": launched,
    }


def collect_unique_tabs(presets: list[Preset]) -> list[TabSpec]:
    """Collect deduplicated tabs from all presets, keyed by (command, pi_role)."""
    seen: set[tuple[str | None, str | None]] = set()
    result: list[TabSpec] = []
    for preset in presets:
        for tab in preset.tabs:
            pi_role = tab.pi.role if tab.pi else None
            key = (tab.command, pi_role)
            if key not in seen:
                seen.add(key)
                result.append(tab)
    return result


def choose_tab_with_fzf(tabs: list[TabSpec]) -> TabSpec:
    fzf_path = shutil_which("fzf")
    if not fzf_path:
        raise CommandError("fzf is required for tab selection")

    lines: list[str] = []
    lookup: dict[str, TabSpec] = {}
    for tab in tabs:
        if tab.pi:
            detail = f"pi: {tab.pi.role}"
        elif tab.command:
            detail = f"cmd: {tab.command}"
        else:
            detail = "shell"
        line = f"{tab.name}\t{detail}"
        lines.append(line)
        lookup[line] = tab

    selected = run_process(
        [fzf_path, "--with-nth=1,2", "--delimiter=\t", "--prompt", "add tab> "],
        input_text="\n".join(lines),
    )
    tab = lookup.get(selected)
    if tab is None:
        raise CommandError("fzf returned an unknown tab selection")
    return tab


def add_single_tab(tab: TabSpec) -> dict[str, Any]:
    """Create a new tab (surface) in the current pane, no split."""
    workspace = get_current_workspace()
    cwd = os.getcwd()
    dir_name = os.path.basename(cwd)

    current_pane = get_root_pane(workspace)

    surface = create_surface(workspace, current_pane)
    title = render_template(tab.name, dir_name=dir_name, cwd=cwd)
    rename_surface(surface, title)

    if tab.command is not None:
        startup_command = render_template(tab.command, dir_name=dir_name, cwd=cwd)
    elif tab.pi is not None:
        startup_command = build_pi_command(tab.pi, dir_name=dir_name, cwd=cwd)
    else:
        startup_command = None

    initialize_tab(surface, startup_command, cwd)

    return {
        "status": "ok",
        "action": "add",
        "tab_title": title,
        "startup_command": startup_command,
        "surface_ref": surface.ref,
        "surface_uuid": surface.uuid,
        "pane_ref": current_pane.ref,
        "pane_uuid": current_pane.uuid,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Launch cmux layouts from TOML presets"
    )
    subparsers = parser.add_subparsers(dest="action")

    launch = subparsers.add_parser("launch", help="Launch a full layout preset")
    launch.add_argument(
        "preset",
        nargs="?",
        help="Layout id; if omitted, choose with fzf",
    )

    add = subparsers.add_parser("add", help="Add a single tab to current pane")

    return parser


def shutil_which(binary: str) -> str | None:
    import shutil

    return shutil.which(binary)


def main(argv: list[str]) -> int:
    raw_args = argv[1:]

    # Backward compat: no subcommand or non-subcommand first arg → treat as "launch"
    if not raw_args or (
        raw_args[0] not in ("launch", "add", "--help", "-h")
        and not raw_args[0].startswith("-")
    ):
        raw_args = ["launch"] + raw_args

    parser = build_parser()
    args = parser.parse_args(raw_args)

    action = getattr(args, "action", None) or "launch"

    preset_dir = Path(__file__).resolve().parent
    try:
        presets = discover_presets(preset_dir)

        if action == "add":
            tabs = collect_unique_tabs(presets)
            tab = choose_tab_with_fzf(tabs)
            result = add_single_tab(tab)
        else:
            preset = resolve_preset(presets, args.preset)
            result = launch_preset(preset)
    except Exception as exc:
        print(json.dumps({"status": "error", "error": str(exc)}, ensure_ascii=False))
        return 1

    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
