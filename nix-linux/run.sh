#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# WiFi power save off (fixes frequent disconnects on Apple Silicon)
WIFI_POWERSAVE_CONF="/etc/NetworkManager/conf.d/wifi-powersave-off.conf"
sudo tee "$WIFI_POWERSAVE_CONF" >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF

WIFI_DISPATCHER="/etc/NetworkManager/dispatcher.d/99-wifi-powersave-off"
sudo tee "$WIFI_DISPATCHER" >/dev/null <<'EOF'
#!/bin/bash
if [ "$2" = "up" ] && [ -n "$(iw dev "$1" info 2>/dev/null)" ]; then
    iw dev "$1" set power_save off
fi
EOF
sudo chmod +x "$WIFI_DISPATCHER"

sudo cp "$ROOT_DIR/services/charge-thresholds.service" /etc/systemd/system/charge-thresholds.service
sudo systemctl daemon-reload
sudo systemctl enable --now charge-thresholds.service || true

# keyd setup (replaces kanata)
sudo groupadd -f keyd
sudo usermod -aG keyd "$USER"

sudo mkdir -p /etc/keyd
sudo ln -sf "$HOME/.config/keyd/default.conf" /etc/keyd/default.conf

if systemctl --user is-active --quiet kanata; then
  systemctl --user disable --now kanata
fi

sudo systemctl enable --now keyd
sudo systemctl restart keyd
