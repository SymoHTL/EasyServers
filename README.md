# EasyServers

**Guided, ready-to-run setups for monitoring, securing and maintaining your servers** — from a single homelab box to a small company fleet.

Every path in this repo is a complete, opinionated stack: copy the folder, follow the README, run `docker compose up -d` (or the setup script), and you have working monitoring, alerting, dashboards and a security baseline. No piecing together ten blog posts.

## Who is this for?

- **Enthusiasts / homelabbers** who want to know what their machines are doing without becoming full-time SREs.
- **Small companies** that run a handful of servers (on-prem or VPS) and need monitoring, alerting, backups and an inventory — "always know what is where".

## Choose your path

| Path | Difficulty | What you get | Best for |
|------|-----------|--------------|----------|
| [01 — Starter](paths/01-starter/) | 🟢 Easy | [Portainer](https://www.portainer.io/) (container management UI), [Beszel](https://beszel.dev/) (lightweight server monitoring + alerts), [Uptime Kuma](https://github.com/louislam/uptime-kuma) (uptime / status pages) | 1–10 servers, minimal effort, beautiful UIs, alerts in minutes |
| [02 — Observability](paths/02-observability/) | 🟡 Medium | [Prometheus](https://prometheus.io/) (metrics), [Grafana](https://grafana.com/) (dashboards), [Loki](https://grafana.com/oss/loki/) + [Alloy](https://grafana.com/docs/alloy/latest/) (centralized logs), [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) (routing alerts to mail/chat) | Teams that want real metrics, log search and alert routing — the industry-standard stack |
| [03 — MicroK8s](paths/03-microk8s/) | 🔴 Advanced | [MicroK8s](https://microk8s.io/) cluster with the built-in observability stack (kube-prometheus-stack, Loki, Tempo) | Running workloads on Kubernetes, multi-node clusters, room to grow |

Not sure? Read [docs/choosing-a-path.md](docs/choosing-a-path.md). Paths are not exclusive — a common combo is Path 01 for day-to-day visibility plus the [security baseline](docs/security-baseline.md) on every host.

## Add-ons (mix & match with any path)

| Add-on | Purpose |
|--------|---------|
| [Traefik reverse proxy](addons/reverse-proxy-traefik/) | One entry point for all web UIs, automatic HTTPS via Let's Encrypt |
| [Homepage dashboard](addons/dashboard-homepage/) | A single start page linking every service on every server — *know what is where* |
| [CrowdSec](addons/crowdsec/) | Crowd-sourced intrusion detection & banning (modern fail2ban) |
| [Restic backups](addons/backups-restic/) | Encrypted, deduplicated backups with retention policy + systemd timer |
| [Watchtower](addons/auto-updates-watchtower/) | Automatic container image updates (with caveats — read the README) |
| [Tailscale VPN](addons/vpn-tailscale/) | Keep admin UIs off the public internet, reach every server from anywhere |

## Security baseline (do this first)

Whatever path you choose, harden the host first:

```bash
# on each Ubuntu/Debian server
sudo bash scripts/harden-ubuntu.sh   # firewall, fail2ban, SSH hardening, auto security updates
sudo bash scripts/install-docker.sh  # Docker Engine + Compose plugin (paths 01 & 02)
```

Details and a manual checklist: [docs/security-baseline.md](docs/security-baseline.md).

## Quick start (Path 01, ~10 minutes)

```bash
git clone https://github.com/SymoHTL/EasyServers.git
cd EasyServers/paths/01-starter
# follow paths/01-starter/README.md — roughly:
docker compose -f portainer/docker-compose.yml up -d
docker compose -f beszel/hub/docker-compose.yml up -d
docker compose -f uptime-kuma/docker-compose.yml up -d
```

Then deploy the Beszel agent on every server you want to monitor and add it in the hub UI.

## Repository layout

```
paths/        Complete stacks — pick one, copy it, run it
addons/       Optional building blocks that work with any path
scripts/      Host setup & hardening scripts (Ubuntu/Debian)
docs/         Guides, the security checklist, inventory template
```

## Conventions

- **Pinned image versions** where stability matters; bump them consciously. Starter-path tools use their vendor-recommended rolling tags.
- **Secrets live in `.env` files** which are gitignored — every stack ships a `.env.example`.
- **Data lives in named volumes or `./data`** so `docker compose down` never destroys state.
- Everything targets **Ubuntu 22.04/24.04 or Debian 12**, but any Docker-capable Linux works.

## Contributing

New paths (e.g. Zabbix, Netdata, k3s), fixes and translations are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
