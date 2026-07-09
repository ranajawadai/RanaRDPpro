#!/usr/bin/env bash
# install-tools.sh — curated offsec / recon toolset for RanaRDP-Pro
# Runs at Docker build time. Keep this list as the single source of truth.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Updating apt"
apt-get update

echo "==> Installing Kali/Debian packaged tools"
apt-get install -y --no-install-recommends \
    nmap sqlmap gobuster ffuf nikto amass masscan \
    sublist3r wpscan feroxbuster nuclei subfinder httpx \
    dirb hydra wfuzz whatweb dnsrecon theharvester \
    metasploit-framework \
    net-tools iputils-ping dnsutils tcpdump \
    && rm -rf /var/lib/apt/lists/* || {
        # Some packages may be missing on a given mirror; retry the rest individually.
        echo "!! bulk install partially failed, continuing with available packages"
    }

# Re-sync lists for any skipped packages
apt-get update >/dev/null 2>&1 || true

# Best-effort individual install for anything that was skipped
for pkg in nmap sqlmap gobuster ffuf nikto amass masscan sublist3r wpscan \
           feroxbuster nuclei subfinder httpx dirb hydra wfuzz whatweb \
           dnsrecon theharvester metasploit-framework; do
    dpkg -s "$pkg" >/dev/null 2>&1 || apt-get install -y --no-install-recommends "$pkg" || true
done
rm -rf /var/lib/apt/lists/*

echo "==> Installing Go-based tools (subfinder/httpx/nuclei) if not present"
export GOPATH=/root/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
mkdir -p "$GOPATH/bin"
command -v subfinder >/dev/null 2>&1 || go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null || true
command -v httpx     >/dev/null 2>&1 || go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null || true
command -v nuclei    >/dev/null 2>&1 || go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null || true
command -v assetfinder >/dev/null 2>&1 || go install -v github.com/tomnomnom/assetfinder@latest 2>/dev/null || true

# Make Go tools available to the kali user too
cp -r "$GOPATH/bin" /opt/gobin 2>/dev/null || true
if [ -d /opt/gobin ]; then
    for b in /opt/gobin/*; do ln -sf "$b" /usr/local/bin/ 2>/dev/null || true; done
fi

echo "==> pipx tools"
pipx install httpx 2>/dev/null || true
pipx install dnsgen 2>/dev/null || true

echo "==> Brave browser (best-effort)"
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave.com/static/linux/brave-browser-archive-keyring.gpg 2>/dev/null || true
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list 2>/dev/null || true
apt-get update >/dev/null 2>&1 || true
apt-get install -y --no-install-recommends brave-browser 2>/dev/null || \
    echo "!! Brave install skipped (falling back to Chromium) — fine."

echo "==> Tool install complete"
