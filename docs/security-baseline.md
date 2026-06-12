# Security baseline

Do this on **every** server before installing anything else. The script
[`scripts/harden-ubuntu.sh`](../scripts/harden-ubuntu.sh) automates the starred
items on Ubuntu/Debian.

## Access

- ★ **SSH keys only** — disable password authentication once your key works.
- ★ **No root login over SSH** (`PermitRootLogin no`); use a sudo user.
- Use a VPN ([Tailscale](../addons/vpn-tailscale/)) or IP allowlist for admin UIs
  (Portainer, Grafana, Beszel, Proxmox, …). **Never** expose them naked to the internet.
- One admin account per human, not a shared login. Enable 2FA everywhere it exists
  (Portainer, Grafana, Uptime Kuma support TOTP).

## Network

- ★ **Firewall on, default deny inbound** (ufw). Open only 22 (or your SSH port), 80/443
  if the host serves web traffic, and whatever you consciously decide.
- Docker bypasses ufw for published ports! Bind internal-only services to localhost
  (`127.0.0.1:9090:9090`) or a VPN interface, and put public ones behind
  [Traefik](../addons/reverse-proxy-traefik/).
- ★ **fail2ban or [CrowdSec](../addons/crowdsec/)** against SSH brute force.

## Updates

- ★ **Unattended security updates** for the OS (`unattended-upgrades`).
- A strategy for container updates: manual `docker compose pull` on a schedule,
  or [Watchtower](../addons/auto-updates-watchtower/) with notifications.

## Data

- **Backups that you have actually restored once.** [Restic](../addons/backups-restic/)
  with the 3-2-1 rule: 3 copies, 2 media, 1 offsite.
- Volumes/bind mounts documented per service (the path READMEs in this repo do this).

## Visibility

- Monitoring + alerting (that's what this repo is for) — you cannot secure what
  you cannot see.
- Keep an [inventory](templates/inventory.md): host, IP, location, services, owner,
  backup status. Review it quarterly.

## Quick check after setup

```bash
sudo ufw status verbose          # default deny incoming?
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication'
sudo fail2ban-client status sshd # or: sudo cscli metrics
sudo ss -tlnp                    # anything listening on 0.0.0.0 that shouldn't?
```
