# AGENTS.md — RanaRDP-Pro (Kali cloud desktop)

You are running **inside RanaRDP-Pro**: a Kali Linux (Debian 12) container with an XFCE
desktop accessible via RDP (port 3389) and a browser (noVNC on $PORT).

## Environment facts
- OS: Kali Linux (rolling). Every Kali/Debian security binary is on `PATH`.
- User: `rana` (home `/home/rana`). You may also use `root`.
- Dev tooling present: `python3`, `pip`/`pipx`, `node` (v22), `npm`, `git`, `zsh`+Oh My Zsh, `tmux`.
- Browsers: `chromium` (and best-effort `brave-browser`).
- Preinstalled recon/offsec tools: `nmap`, `sqlmap`, `gobuster`, `ffuf`, `nuclei`,
  `subfinder`, `httpx`, `amass`, `nikto`, `masscan`, `whatweb`, `wpscan`, `feroxbuster`,
  `theharvester`, `metasploit-framework` (`msfconsole`), and more.

## How to operate
- Prefer invoking the real Kali binaries directly (e.g. `nmap -sC -sV target.com`).
  They are first-class on PATH — you are NOT sandboxed away from them.
- For automated recon, chain tools: `subfinder -d target.com | httpx -silent`.
- Long/recurring tasks: use `tmux` so work survives disconnects.
- To expand the toolkit, run `bash /opt/scripts/install_bosk_tools.sh`
  (custom command: `bosk`). It pulls
  https://github.com/trimstray/the-book-of-secret-knowledge and installs a curated subset.

## Rules
- Only target systems the user is **authorized** to test.
- Keep the desktop responsive; avoid unbounded memory use.
- Persist useful notes/scripts under `/home/rana` (or a mounted volume).
