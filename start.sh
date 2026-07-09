#!/usr/bin/env bash
# start.sh — RanaRDP-Pro entrypoint
set -euo pipefail

export PORT="${PORT:-8080}"
RDP_PASS="${RDP_PASSWORD:-rana}"

# Set passwords
echo "rana:${RDP_PASS}" | chpasswd 2>/dev/null || true
echo "root:${RDP_PASS}" | chpasswd 2>/dev/null || true

# Ensure xsession files exist
for h in /root /home/rana; do
    mkdir -p "$h/.vnc"
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_SESSION_TYPE=x11\nexec startxfce4\n' > "$h/.vnc/xstartup"
    chmod +x "$h/.vnc/xstartup"
    printf 'startxfce4\n' > "$h/.xsession"
    chmod +x "$h/.xsession"
done
chown -R rana:rana /home/rana/.vnc /home/rana/.xsession 2>/dev/null || true

# Fix startwm.sh (xrdp calls this on session start)
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

# Start xrdp daemon (it forks to background — that's OK)
echo "==> Starting xrdp daemon"
/usr/sbin/xrdp &
sleep 1

echo "==> Starting xrdp-sesman daemon"
/usr/sbin/xrdp-sesman &
sleep 1

echo "==> Starting supervisord (Xvnc + XFCE + noVNC on :${PORT})"
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
