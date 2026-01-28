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

def main():
    if len(sys.argv) < 2: return
    direction = sys.argv[1]

    all_windows = query("-m query --windows")
    
    valid = sorted([
        w for w in all_windows 
        if not w.get("is-minimized") and 
           not w.get("is-hidden") and 
           not w.get("is-floating")
    ], key=lambda w: (w["space"], w["frame"]["x"], w["frame"]["y"], w["id"]))

    if not valid: return

    focused_idx = next((i for i, w in enumerate(valid) if w.get("has-focus")), None)

    if focused_idx is None:
        subprocess.run(f"{YABAI} -m window --focus {valid[0]['id']}", shell=True)
        return

    if direction == "east":
        target_idx = (focused_idx + 1) % len(valid)
    else:
        target_idx = (focused_idx - 1 + len(valid)) % len(valid)

    target_id = valid[target_idx]["id"]
    subprocess.run(f"{YABAI} -m window --focus {target_id}", shell=True)

if __name__ == "__main__":
    main()
