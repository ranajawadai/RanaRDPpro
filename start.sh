#!/usr/bin/env bash
# start.sh — RanaRDP-Pro entrypoint (xrdp as daemon, supervisord for foreground)
set -euo pipefail

export PORT="${PORT:-8080}"
RDP_PASS="${RDP_PASSWORD:-rana}"

# Set passwords
echo "rana:${RDP_PASS}" | chpasswd 2>/dev/null || true
echo "root:${RDP_PASS}" | chpasswd 2>/dev/null || true

# Session files for xrdp and VNC
for h in /root /home/rana; do
    mkdir -p "$h/.vnc"
    cat > "$h/.vnc/xstartup" << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
exec startxfce4
EOF
    chmod +x "$h/.vnc/xstartup"
    printf 'startxfce4\n' > "$h/.xsession"
    chmod +x "$h/.xsession"
done
chown -R rana:rana /home/rana/.vnc /home/rana/.xsession 2>/dev/null || true

# Fix startwm.sh — xrdp calls this to start the desktop
cat > /etc/xrdp/startwm.sh << 'WMEOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
exec startxfce4
WMEOF
chmod +x /etc/xrdp/startwm.sh

# Generate xrdp RSA keys if missing
[ -f /etc/xrdp/rsakeys.ini ] || xrdp-keygen xrdp >/dev/null 2>&1 || true

# Start xrdp + sesman as background daemons (they fork — that's OK)
echo "==> Starting xrdp"
/usr/sbin/xrdp &
sleep 2
echo "==> Starting xrdp-sesman"
/usr/sbin/xrdp-sesman &
sleep 1

# Verify xrdp is listening
ss -tlnp | grep 3389 && echo "  xrdp OK on 3389" || echo "  WARN: xrdp not listening on 3389"

echo "==> Starting supervisord (Xvnc + XFCE4 + noVNC on :${PORT})"
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
