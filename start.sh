#!/usr/bin/env bash
# start.sh — RanaRDP-Pro entrypoint
# xrdp/xrdp-sesman run as daemons, supervisord manages foreground processes
set -u

export PORT="${PORT:-8080}"
RDP_PASS="${RDP_PASSWORD:-rana}"

echo "==> Setting passwords"
echo "rana:${RDP_PASS}" | chpasswd 2>/dev/null || true
echo "root:${RDP_PASS}" | chpasswd 2>/dev/null || true

# --- Session files ---
SESSION_SCRIPT='#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
exec startxfce4'

for h in /root /home/rana; do
    mkdir -p "$h/.vnc"
    printf '%s\n' "$SESSION_SCRIPT" > "$h/.vnc/xstartup"
    chmod +x "$h/.vnc/xstartup"
    printf 'startxfce4\n' > "$h/.xsession"
    chmod +x "$h/.xsession"
done
chown -R rana:rana /home/rana/.vnc /home/rana/.xsession 2>/dev/null || true

# --- Fix xrdp startwm.sh ---
printf '#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_SESSION_TYPE=x11\nexec startxfce4\n' > /etc/xrdp/startwm.sh
chmod +x /etc/xrdp/startwm.sh

# --- Generate RSA keys ---
xrdp-keygen xrdp 2>/dev/null || true

# --- Start xrdp (daemonizes) ---
echo "==> Starting xrdp daemon"
/usr/sbin/xrdp || true
sleep 2

echo "==> Starting xrdp-sesman daemon"
/usr/sbin/xrdp-sesman || true
sleep 1

# --- Verify ---
echo "==> Checking xrdp port"
ss -tlnp 2>/dev/null | grep 3389 || echo "  xrdp may need a moment to bind"

echo "==> Starting supervisord (Xvnc + XFCE + noVNC on :${PORT})"
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
