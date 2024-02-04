import subprocess
import json
import re

current_windows = subprocess.check_output(["yabai", "-m", "query", "--windows"])

parsed_json = json.loads(current_windows)

app_to_window = {
    "^Docker": "8",
    "^wezterm": "2",
    "^WezTerm": "2",
    "^Spark": "7",
    "^Emacs": "5",
    "^Telegram": "1",
    "^Mattermost": "1",
    "^Brave": "3",
    "^Google": "4",
    "^Session": "8",
    "^Spotify": "6",
    "^OpenVPN": "8",
    "^Whalebird": "8",
    "^Couch": "8",
    "^Firefox": "8",
    "^Android": "8",
}

for window in parsed_json:
    for regexp in app_to_window:
        if not re.search(regexp, window["app"]):
            continue
        space = app_to_window[regexp]
        print(
            "Moving window {}:{}, app name: {}, to space {}".format(
                window["id"], window["app"], window["title"], space
            )
        )
        subprocess.run(["yabai", "-m", "window", f'{window["id"]}', "--space", space])
