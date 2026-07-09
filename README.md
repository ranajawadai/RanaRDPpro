# RanaRDP-Pro

A powerful, **Railway-deployable Kali Linux cloud desktop** with XFCE, XRDP, browser-based
noVNC access, and **OpenCode CLI preinstalled inside the same container** so it can 100% drive
the Kali toolchain. Ships a curated recon/offsec toolset and an auto-installer wired into
[the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge).

> Deploy with one GitHub push to Railway. Or run it anywhere Docker runs (your 799 GB RDP/VPS).

---

## What you get

- **OS**: Kali Linux (Rolling, Debian 12 based) — every Kali binary is on PATH for OpenCode.
- **Desktop**: XFCE4 (lightweight, fast).
- **Access**:
  - 🌐 **Browser** via noVNC on Railway `$PORT` (no client needed).
  - 🖥️ **RDP** client on port `3389`.
- **AI**: OpenCode CLI installed in-container, preconfigured (`config.toml` + `AGENTS.md`) and
  a `bosk` custom command that pulls & installs tools from the-book-of-secret-knowledge.
- **Dev**: Python 3, pip/pipx, Node.js 22 LTS, npm, Git, zsh + Oh My Zsh, tmux.
- **Browser**: Chromium (reliable) + best-effort Brave.
- **Recon / offsec (curated)**: nmap, sqlmap, gobuster, ffuf, nuclei, amass, subfinder,
  httpx, nikto, masscan, sublist3r, wpscan, feroxbuster, and more.

---

## Deploy to Railway (one push)

1. Create a repo `RanaRDPpro` on GitHub and push this folder:
   ```bash
   git init
   git remote add origin https://github.com/YOURUSER/RanaRDPpro.git
   git add -A && git commit -m "feat: RanaRDP-Pro Kali cloud desktop"
   git push -u origin main
   ```
2. Railway → **New Project** → **Deploy from GitHub** → select the repo.
3. Railway auto-detects the `Dockerfile`, builds (≈15–25 min), and gives you a public URL.
4. Open the URL → noVNC desktop loads. For RDP, expose TCP `3389` in Railway and connect
   with an RDP client (user `rana`, password from `RDP_PASSWORD`, default `rana`).

### Required Railway variables

| Variable        | Default | Notes                                   |
| --------------- | ------- | --------------------------------------- |
| `PORT`          | `8080`  | noVNC web port (set automatically).      |
| `RDP_PASSWORD`  | `rana`  | Password for the `rana` user (baked in; change if you like). |
| `ANTHROPIC_API_KEY` | – | Enables **Claude** models in OpenCode. |
| `OPENAI_API_KEY`    | – | Enables **ChatGPT** (gpt-4o, o3, ...) in OpenCode. |
| `GOOGLE_API_KEY`    | – | Enables **Gemini** (gemini-2.5-pro, ...) in OpenCode. |
| `OPENROUTER_API_KEY`| – | Enables **OpenRouter** — hundreds of models incl. **Xiaomi MiMo v2.5 Pro**, DeepSeek, Qwen, Llama, etc. |

> **Username is NOT a variable** — it is fixed to `rana` inside the image. Only set the
> password above and whichever provider API key(s) you want. Inside OpenCode, press the
> model picker (or `opencode models`) to switch between providers/models. To use MiMo v2.5 Pro:
> set `OPENROUTER_API_KEY` and pick `openrouter/xiaomi/mimo-v2-5-pro`.

> ⚠️ Railway free RAM is small; XFCE + a browser wants **>1 GB**. Use a paid plan or it may OOM.

---

## Run anywhere with Docker (your 799 GB RDP / VPS)

```bash
docker build -t ranardp-pro .
docker run -d --name ranardp \
  -p 8080:8080 -p 3389:3389 \
  -e RDP_PASSWORD='yourStrongPass' \
  -v ranardp-home:/home/rana \
  ranardp-pro
```
Open `http://<host>:8080`. RDP → `host:3389` (user `rana`).

---

## Using OpenCode inside the desktop

Open a terminal in the desktop and run `opencode`. It is preconfigured to know it lives in
Kali (see `AGENTS.md`). Try:

- `> install bosk tools`  → runs the auto-installer from the-book-of-secret-knowledge
  (also available as the `bosk` custom command, or `bash /opt/scripts/install_bosk_tools.sh`).
- Any pentest task, e.g. `> run a subdomain enumeration against example.com using subfinder+httpx`.
  OpenCode invokes the Kali binaries directly because they are all on PATH.

Set your model provider key (env), then `opencode auth` or just start — OpenCode reads
`ANTHROPIC_API_KEY` / `OPENAI_API_KEY` automatically.

---

## Project layout

```
Dockerfile                  # Kali + XFCE + XRDP + noVNC + OpenCode
railway.json               # Railway deploy config
supervisord.conf           # starts xrdp + vnc + noVNC
start.sh                   # entrypoint (runs supervisord)
install-tools.sh           # curated apt/go tool install (build stage)
xrdp.ini                  # xrdp config overlay
scripts/
  setup.sh                # first-run hardening / user setup
  install_bosk_tools.sh   # pulls the-book-of-secret-knowledge & installs curated tools
  update.sh               # apt update + tool refresh
config/opencode/          # config.toml + AGENTS.md (copied to container)
.opencode/command/bosk.md # OpenCode custom command
.github/workflows/        # CI docker build test
```

## Notes / honest limitations

- **Docker daemon** is not available inside Railway; the Docker *CLI* is installed but the
  daemon won't run there. Use a VPS for Docker-in-Docker.
- **Image size** ≈ 3–4 GB. If Railway rejects build size/time, Render or Fly.io are drop-in
  alternatives (same Dockerfile).
- Use all tooling **only on systems you are authorized to test**.
