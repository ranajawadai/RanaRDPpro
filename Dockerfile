# syntax=docker/dockerfile:1

# ----------------------------------------------------------------------------
# RanaRDP-Pro — Kali Linux cloud desktop (XFCE + XRDP + noVNC + OpenCode)
# Base: kalilinux/kali-rolling (Debian 12, authentic Kali toolchain)
# ----------------------------------------------------------------------------
FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PASSWORD=rana

# ---- 1. System + desktop + remote access --------------------------------
# Packages: core, desktop, remote access (RDP+VNC/noVNC), dev, browser, golang
# NOTE: nodejs/npm intentionally omitted here — NodeSource provides Node 22+npm.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg git unzip xz-utils sudo nano vim \
        xfce4 xfce4-goodies dbus-x11 x11-utils x11-xserver-utils \
        xrdp tigervnc-standalone-server tigervnc-common novnc websockify \
        supervisor \
        python3 python3-pip python3-venv pipx zsh tmux \
        chromium \
        golang-go \
    && rm -rf /var/lib/apt/lists/*

# ---- 2. Node.js 22 LTS (NodeSource) ------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# ---- 3. Curated offsec / recon toolset --------------------------------
# Runs the external installer script so tool lists stay in one place.
COPY install-tools.sh /opt/scripts/install-tools.sh
RUN chmod +x /opt/scripts/install-tools.sh && /opt/scripts/install-tools.sh

# ---- 4. OpenCode CLI (inside the container = 100% Kali access) ---------
RUN npm install -g opencode-ai

# ---- 5. Oh My Zsh ------------------------------------------------------
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    || true

# ---- 6. User + passwords ----------------------------------------------
RUN id rana >/dev/null 2>&1 || useradd -m -s /bin/zsh rana \
    && echo "rana:rana" | chpasswd \
    && echo "root:rana" | chpasswd \
    && usermod -aG sudo rana \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true

# ---- 7. VNC / XFCE session for noVNC ----------------------------------
RUN mkdir -p /root/.vnc /home/rana/.vnc \
    && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' \
       > /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup \
    && cp /root/.vnc/xstartup /home/rana/.vnc/xstartup \
    && chown -R rana:rana /home/rana/.vnc

# ---- 8. xrdp config overlay -------------------------------------------
COPY xrdp.ini /etc/xrdp/xrdp.ini
RUN printf 'startxfce4\n' > /etc/skel/.xsession \
    && cp /etc/skel/.xsession /home/rana/.xsession \
    && chown rana:rana /home/rana/.xsession

# ---- 9. OpenCode config + AGENTS.md -----------------------------------
COPY config/opencode/config.toml /root/.config/opencode/config.toml
COPY config/opencode/AGENTS.md /root/.config/opencode/AGENTS.md
RUN mkdir -p /home/rana/.config/opencode \
    && cp /root/.config/opencode/config.toml /home/rana/.config/opencode/config.toml \
    && cp /root/.config/opencode/AGENTS.md /home/rana/.config/opencode/AGENTS.md \
    && chown -R rana:rana /home/rana/.config

# ---- 10. OpenCode custom command (bosk) -------------------------------
COPY .opencode/command/bosk.md /root/.opencode/command/bosk.md
RUN mkdir -p /home/rana/.opencode/command \
    && cp /root/.opencode/command/bosk.md /home/rana/.opencode/command/bosk.md \
    && chown -R rana:rana /home/rana/.opencode

# ---- 11. Scripts + entrypoint -----------------------------------------
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389
EXPOSE 8080
ENTRYPOINT ["/start.sh"]
