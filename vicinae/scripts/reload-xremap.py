#!/usr/bin/env python3
# @vicinae.schemaVersion 1
# @vicinae.title Reload xremap
# @vicinae.mode fullOutput

import subprocess
import os

try:
    subprocess.run(["killall", "-s", "SIGINT", "xremap"], check=False)
except Exception as e:
    print(f"Error killing xremap: {e}")

try:
    config_path = os.path.expanduser("~/.config/xremap/config.yml")
    subprocess.Popen(
        ["xremap", config_path],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True
    )
    subprocess.run(["notify-send", "-t", "500", "-u", "low", "Xremap restarted"])
except Exception as e:
    subprocess.run(["notify-send", "-t", "500", "-u", "low", "Faield to restart"])
    

