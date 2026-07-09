#!/usr/bin/env bash
# scripts/install_bosk_tools.sh
# Pulls the-book-of-secret-knowledge and installs a curated subset of its tooling
# into this Kali environment. Designed to be run by OpenCode (custom command: bosk)
# or manually from inside the desktop.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export GOPATH=/root/go
export PATH=$GOPATH/bin:/usr/local/go/bin:/usr/local/bin:$PATH

REPO_URL="https://github.com/trimstray/the-book-of-secret-knowledge"
WORKDIR="/opt/bosk"
LOG="/var/log/bosk_install.log"

echo "==> [bosk] cloning reference list: $REPO_URL"
mkdir -p "$WORKDIR"
git clone --depth 1 "$REPO_URL" "$WORKDIR/repo" >>"$LOG" 2>&1 \
  || echo "!! clone failed (offline?) — continuing with package installs"

echo "==> [bosk] installing curated Kali/Debian packages"
apt-get update >>"$LOG" 2>&1
apt-get install -y --no-install-recommends \
    nmap sqlmap gobuster ffuf nikto amass masscan \
    sublist3r wpscan feroxbuster nuclei subfinder httpx \
    dirb hydra wfuzz whatweb dnsrecon theharvester \
    metasploit-framework net-tools dnsutils tcpdump \
    >>"$LOG" 2>&1 || echo "!! some packages skipped"

echo "==> [bosk] Go-based tools"
for tool in \
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" \
  "github.com/projectdiscovery/httpx/cmd/httpx@latest" \
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest" \
  "github.com/tomnomnom/assetfinder@latest" \
  "github.com/lc/gau/v2/cmd/gau@latest" ; do
    echo "  - go install $tool"
    go install "$tool" >>"$LOG" 2>&1 || echo "  !! failed: $tool"
done
mkdir -p /opt/gobin && cp -r "$GOPATH/bin/." /opt/gobin/ 2>/dev/null || true
for b in /opt/gobin/*; do ln -sf "$b" /usr/local/bin/ 2>/dev/null || true; done

echo "==> [bosk] python tooling via pipx"
pipx install httpx >>"$LOG" 2>&1 || true
pipx install dnsgen >>"$LOG" 2>&1 || true
pipx install arjun >>"$LOG" 2>&1 || true

echo "==> [bosk] Done. Log: $LOG"
echo "    Reference repo cached at: $WORKDIR/repo"
