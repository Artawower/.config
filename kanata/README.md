# Kanata setup

This replaces keyd mappings with kanata.

## Install

Use your package manager or release binary from https://github.com/jtroo/kanata.

## Config

Config file: `~/.config/kanata/kanata.kbd`

## Run (systemd --user)

Create a user service:

```
# ~/.config/systemd/user/kanata.service
[Unit]
Description=kanata keyboard remapper
After=graphical-session.target

[Service]
ExecStart=/home/darkawower/.nix-profile/bin/kanata -c %h/.config/kanata/kanata.kbd
Restart=always

[Install]
WantedBy=default.target
```

Enable:

```
systemctl --user daemon-reload
systemctl --user enable --now kanata
```

## Notes

- Stop keyd before running kanata.
- If key names differ on your keyboard, run kanata with `--debug` and adjust `defsrc`.
