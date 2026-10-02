#!/usr/bin/env bash
# Install and apply the i8kmon fan curve for Dell 15 DC15250.
# Run:  bash ~/dell-15-dc15250-fan-config/install.sh

set -euo pipefail

CONF_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/i8kmon.conf"
CONF_DST="/etc/i8kutils/i8kmon.conf"

echo "==> Installing packages"
yay -S --needed i8kutils dell-bios-fan-control-git

if [[ ! -f "$CONF_SRC" ]]; then
    echo "error: $CONF_SRC not found" >&2
    exit 1
fi

echo "==> Backing up existing config"
if [[ -f "$CONF_DST" ]]; then
    sudo cp "$CONF_DST" "$CONF_DST.bak"
    echo "    saved to $CONF_DST.bak"
else
    echo "    no existing config, nothing to back up"
fi

echo "==> Installing config"
sudo mkdir -p "$(dirname "$CONF_DST")"
sudo cp "$CONF_SRC" "$CONF_DST"

echo "==> Restarting i8kmon"
sudo systemctl restart i8kmon

echo "==> State"
i8kctl || true
systemctl is-active i8kmon || true
systemctl is-active dell-bios-fan-control || true

echo
echo "Done. Watch it with:"
echo "  watch -n2 'echo \"cpu=\$(( \$(cat /sys/class/hwmon/hwmon3/temp1_input)/1000 ))C rpm=\$(cat /sys/class/hwmon/hwmon3/fan1_input)\"'"
