---
name: bosk
description: Pull the-book-of-secret-knowledge and auto-install a curated subset of its tools into this Kali environment.
---

# /bosk — install tools from the-book-of-secret-knowledge

The user wants the offsec/recon tooling referenced in
<https://github.com/trimstray/the-book-of-secret-knowledge> available in this Kali desktop.

## Steps
1. Run the bundled installer:
   ```bash
   bash /opt/scripts/install_bosk_tools.sh
   ```
2. After it finishes, verify a few tools resolve on PATH:
   ```bash
   for t in nmap sqlmap gobuster ffuf nuclei subfinder httpx amass nikto; do
     command -v "$t" >/dev/null && echo "OK  $t" || echo "MISSING $t"
   done
   ```
3. Report what was installed and any tool that failed (and why).

Do not invent tools not present in the repo or installers; rely on the script and the
Kali/Debian package manager. Only operate on systems the user is authorized to test.
