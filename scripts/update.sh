#!/usr/bin/env bash
# scripts/update.sh — refresh system + tooling in RanaRDP-Pro
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "==> apt update + upgrade"
apt-get update && apt-get -y upgrade >>/var/log/update.log 2>&1 || true

echo "==> refresh Go tools"
export GOPATH=/root/go
export PATH=$GOPATH/bin:/usr/local/go/bin:/usr/local/bin:$PATH
for tool in \
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" \
  "github.com/projectdiscovery/httpx/cmd/httpx@latest" \
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"; do
    go install "$tool" >>/var/log/update.log 2>&1 || true
done
[ -d /opt/gobin ] && cp -r "$GOPATH/bin/." /opt/gobin/ 2>/dev/null || true

echo "==> update complete"
