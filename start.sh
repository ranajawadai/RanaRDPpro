#!/usr/bin/env bash
# start.sh — RanaRDP-Pro entrypoint
set -euo pipefail

export PORT="${PORT:-8080}"
RDP_PASS="${RDP_PASSWORD:-rana}"

# Ensure the rana user password matches the provided env (default: rana)
echo "rana:${RDP_PASS}" | chpasswd 2>/dev/null || true
echo "root:${RDP_PASS}"  | chpasswd 2>/dev/null || true

# Make sure xstartup exists for both users
for h in /root /home/rana; do
    mkdir -p "$h/.vnc"
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > "$h/.vnc/xstartup"
    chmod +x "$h/.vnc/xstartup"
done
chown -R rana:rana /home/rana/.vnc 2>/dev/null || true

# Generate xrdp RSA keys if missing
[ -f /etc/xrdp/rsakeys.ini ] || xrdp-keygen xrdp >/dev/null 2>&1 || true

echo "==> Starting supervisord (xrdp + vnc + noVNC on :${PORT})"
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
