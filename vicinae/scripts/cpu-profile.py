#!/usr/bin/env python3
# @vicinae.schemaVersion 1
# @vicinae.title CPU Thermal Profile
# @vicinae.mode silent

import subprocess
import os
import json

STATE_FILE = os.path.expanduser("~/.local/state/cpu-profile.json")
HELPER = os.path.expanduser("~/.local/bin/cpu-profile-apply")

# M1 Max topology: policy0 = E-cores (0-1), policy2/policy6 = P-cores (2-9)
PROFILES = {
    "performance": {
        "icon": "\U0001f525",
        "e_max": 2064000,
        "p_max": 3036000,
        "gov": "schedutil",
    },
    "balanced": {
        "icon": "\u2696\ufe0f",
        "e_max": 2064000,
        "p_max": 2448000,
        "gov": "schedutil",
    },
    "powersave": {
        "icon": "\u2744\ufe0f",
        "e_max": 1332000,
        "p_max": 1752000,
        "gov": "powersave",
    },
}

ORDER = ["performance", "balanced", "powersave"]


def read_state() -> str:
    try:
        with open(STATE_FILE) as f:
            return json.load(f).get("profile", "performance")
    except (FileNotFoundError, json.JSONDecodeError):
        return "performance"


def write_state(profile: str):
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump({"profile": profile}, f)


def build_dmenu_items(current: str) -> str:
    lines = []
    for name in ORDER:
        p = PROFILES[name]
        e_ghz = p["e_max"] / 1_000_000
        p_ghz = p["p_max"] / 1_000_000
        marker = " (active)" if name == current else ""
        lines.append(
            f"{p['icon']} {name}{marker}  —  E:{e_ghz:.1f} P:{p_ghz:.1f} GHz  [{p['gov']}]"
        )
    return "\n".join(lines)


def apply_profile(name: str) -> bool:
    p = PROFILES[name]
    result = subprocess.run(
        ["sudo", HELPER, str(p["e_max"]), str(p["p_max"]), p["gov"]],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        subprocess.run(
            [
                "notify-send",
                "-t",
                "3000",
                "-u",
                "critical",
                f"CPU Profile: failed to apply {name}",
                result.stderr.strip() or "Unknown error",
            ]
        )
        return False
    return True


def main():
    current = read_state()
    items = build_dmenu_items(current)

    result = subprocess.run(
        ["vicinae", "dmenu", "-n", "CPU Thermal Profile", "-p", "Select profile..."],
        input=items,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0 or not result.stdout.strip():
        return

    selection = result.stdout.strip()

    chosen = None
    for name in ORDER:
        if name in selection:
            chosen = name
            break

    if not chosen or chosen == current:
        return

    if apply_profile(chosen):
        write_state(chosen)
        p = PROFILES[chosen]
        e_ghz = p["e_max"] / 1_000_000
        p_ghz = p["p_max"] / 1_000_000
        subprocess.run(
            [
                "notify-send",
                "-t",
                "1500",
                "-u",
                "low",
                f"{p['icon']} CPU: {chosen}",
                f"E-cores: {e_ghz:.1f} GHz | P-cores: {p_ghz:.1f} GHz | Gov: {p['gov']}",
            ]
        )


if __name__ == "__main__":
    main()
