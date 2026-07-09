# RanaRDP-Pro — project memory (auto-generated)

- **Type**: Dockerized Kali Linux cloud desktop (RDP + noVNC), deployable to Railway.
- **Key decision**: Windows 11 dropped — Railway runs Linux only. Kali Rolling used instead.
- **OpenCode**: installed INSIDE the container so it 100% uses the Kali toolchain.
- **Tools**: curated recon/offsec set; auto-installer wired to the-book-of-secret-knowledge
  via `scripts/install_bosk_tools.sh` (OpenCode custom command `bosk`).
- **Deploy**: GitHub push -> Railway (Dockerfile). Also runnable on any Docker host
  (user's 799 GB RDP/VPS) with `docker build` + `docker run`.
- **Limitations**: no Docker daemon in Railway; image ~3-4 GB; needs >1 GB RAM.
