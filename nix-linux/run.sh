#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo cp "$ROOT_DIR/services/charge-thresholds.service" /etc/systemd/system/charge-thresholds.service
sudo systemctl daemon-reload
sudo systemctl enable --now charge-thresholds.service || true

KANATA_CONFIG="$HOME/.config/kanata/kanata.kbd"
KANATA_SERVICE="$HOME/.config/systemd/user/kanata.service"
KANATA_UINPUT_RULE="/etc/udev/rules.d/99-kanata-uinput.rules"

if [[ ! -f "$KANATA_CONFIG" ]]; then
  echo "Missing kanata config: $KANATA_CONFIG" >&2
  exit 1
fi

if systemctl is-active --quiet keyd; then
  sudo systemctl disable --now keyd
fi

sudo modprobe uinput
sudo groupadd -f uinput
sudo usermod -aG input,uinput "$USER"

sudo tee "$KANATA_UINPUT_RULE" >/dev/null <<'EOF'
KERNEL=="uinput", GROUP="uinput", MODE="0660"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger

mkdir -p "$(dirname "$KANATA_SERVICE")"
KANATA_BIN="$(command -v kanata || true)"
if [[ -z "$KANATA_BIN" ]]; then
  echo "kanata binary not found in PATH" >&2
  exit 1
fi

cat > "$KANATA_SERVICE" <<EOF
[Unit]
Description=kanata keyboard remapper
After=graphical-session.target

[Service]
ExecStart=$KANATA_BIN -c %h/.config/kanata/kanata.kbd --no-wait
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now kanata

if ! systemctl --user is-active --quiet kanata; then
  echo "kanata service failed to start" >&2
  systemctl --user status kanata >&2 || true
  exit 1
fi
