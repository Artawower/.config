#!/usr/bin/env python3
# @vicinae.schemaVersion 1
# @vicinae.title Lock
# @vicinae.mode silent

import subprocess

CMD = [
    "qs",
    "-c",
    "noctalia-shell",
    "ipc",
    "call",
    "lockScreen",
    "lock",
]

try:
    subprocess.run(CMD, check=True)
except Exception:
    subprocess.run([
        "notify-send",
        "-t", "800",
        "-u", "low",
        "Failed to lock screen"
    ])

