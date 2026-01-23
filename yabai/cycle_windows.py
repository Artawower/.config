import json
import subprocess
import sys

YABAI = "/opt/homebrew/bin/yabai"

def query(cmd):
    try:
        res = subprocess.check_output(f"{YABAI} {cmd}", shell=True).decode('utf-8')
        return json.loads(res) if res else []
    except:
        return []

def execute(cmd):
    return subprocess.run(f"{YABAI} {cmd}", shell=True).returncode

def get_tiled_windows(space_idx=None):
    q = "-m query --windows --space"
    if space_idx:
        q += f" {space_idx}"
    windows = query(q)
    return [
        w for w in windows 
        if not w["is-minimized"] 
        and w["can-move"] 
        and not w["is-floating"]
    ]

def main():
    if len(sys.argv) < 2:
        return
    direction = sys.argv[1]

    windows = get_tiled_windows()
    windows.sort(key=lambda w: (w["frame"]["x"], w["frame"]["y"]))
    
    focused_idx = next((i for i, w in enumerate(windows) if w["has-focus"]), None)

    target_window = None
    if direction == "east":
        if focused_idx is not None and focused_idx < len(windows) - 1:
            target_window = windows[focused_idx + 1]
    elif direction == "west":
        if focused_idx is not None and focused_idx > 0:
            target_window = windows[focused_idx - 1]

    if target_window:
        execute(f"-m window --focus {target_window['id']}")
        return

    current_space = query("-m query --spaces --space")
    current_index = current_space["index"]
    all_spaces = query("-m query --spaces")
    max_index = max(s["index"] for s in all_spaces)

    if direction == "east":
        target_index = current_index + 1 if current_index < max_index else 1
        to_start = True
    else:
        target_index = current_index - 1 if current_index > 1 else max_index
        to_start = False

    execute(f"-m space --focus {target_index}")
    
    new_windows = get_tiled_windows(target_index)
    if new_windows:
        new_windows.sort(key=lambda w: (w["frame"]["x"], w["frame"]["y"]))
        target = new_windows[0] if to_start else new_windows[-1]
        execute(f"-m window --focus {target['id']}")

if __name__ == "__main__":
    main()
