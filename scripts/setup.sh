#!/usr/bin/env bash
# scripts/setup.sh — first-run hardening for RanaRDP-Pro
set -euo pipefail

echo "==> RanaRDP-Pro setup"
# Ensure user exists
id kali >/dev/null 2>&1 || useradd -m -s /bin/zsh kali
echo "kali:${RDP_PASSWORD:-kali}" | chpasswd 2>/dev/null || true

# Symlink Go tools into PATH if present
if [ -d /opt/gobin ]; then
  for b in /opt/gobin/*; do ln -sf "$b" /usr/local/bin/ 2>/dev/null || true; done
fi

# Make OpenCode available to the kali user's shell
ln -sf "$(command -v opencode)" /usr/local/bin/opencode 2>/dev/null || true

# zsh default for kali
chsh -s /bin/zsh kali 2>/dev/null || true

echo "==> setup done. User: kali | RDP:3389 | Web(noVNC): \$PORT"
