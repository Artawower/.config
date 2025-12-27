import subprocess
import json
import re

current_windows = subprocess.check_output(["yabai", "-m", "query", "--windows"])

parsed_json = json.loads(current_windows)

app_to_window = {
    "^Docker": "thrash",
    "^wezterm": "term",
    "^Ghostty": "term",
    "^WezTerm": "6",
    "^Spark": "thrash",
    "^Emacs": "dev",
    "^Telegram": "social",
    "^Mattermost": "social",
    "^Brave": "www",
    "^Google": "other",
    "^Session": "thrash",
    "^Spotify": "entertainment",
    "^OpenVPN": "thrash",
    "^Whalebird": "thrash",
    "^Couch": "thrash",
    "^Firefox": "thrash",
    "^Android": "thrash",
    "^Discord": "entertainment",
    "^Lightroom": "entertainment",
    "^Chromium": "10",
    "^OrbStack": "12"
}

def order_windows():
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


if __name__ == "__main__":
    order_windows()
