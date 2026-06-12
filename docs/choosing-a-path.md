# Choosing a path

Three questions decide it:

## 1. How many servers, and who maintains them?

- **1–10 servers, one person, limited time** → **Path 01 (Starter)**. Beszel gives you CPU/RAM/disk/network/temperature per host, Docker container stats, and alerts (email, Discord, Telegram, …) with almost zero configuration. Uptime Kuma watches your websites and services from the outside. Portainer manages containers without SSH gymnastics.
- **A team, or you need to *query* metrics and logs** → **Path 02 (Observability)**. Prometheus + Grafana + Loki is the industry standard: powerful dashboards, PromQL/LogQL queries, alert routing with silences and escalation. More moving parts, more reward.
- **You run (or want to run) workloads on Kubernetes** → **Path 03 (MicroK8s)**. The cluster comes with its own observability stack; don't bolt Path 02 onto it.

## 2. Pull or push monitoring?

- **Beszel (Path 01)**: hub connects to lightweight agents. Trivial to set up, fixed feature set.
- **Prometheus (Path 02)**: scrapes exporters over HTTP. Infinitely extensible — there is an exporter for almost everything (PostgreSQL, nginx, SMART disks, UPS devices, …).

## 3. Where do alerts go?

All paths can notify you:

- **Path 01**: Beszel and Uptime Kuma both have built-in notification providers (SMTP, Discord, Telegram, ntfy, webhooks, …) configured in the UI.
- **Path 02**: Alertmanager routes alerts by label — different teams, different channels, silences, inhibition rules.
- **Path 03**: Alertmanager is included in the MicroK8s observability addon.

## Sane combinations

| Scenario | Recommendation |
|----------|----------------|
| Homelab, 3 machines | Path 01 + [security baseline](security-baseline.md) + [Tailscale](../addons/vpn-tailscale/) |
| Small company, 10 VPS, 1 admin | Path 01 + [Traefik](../addons/reverse-proxy-traefik/) + [CrowdSec](../addons/crowdsec/) + [Restic backups](../addons/backups-restic/) |
| Company with a dev team, on-prem + cloud | Path 02 + [Homepage](../addons/dashboard-homepage/) + backups + VPN |
| Platform team, container workloads | Path 03, expose Grafana via ingress, GitOps later |

## "Always know what is where"

Whatever you pick, keep an inventory. Start with the template in
[docs/templates/inventory.md](templates/inventory.md), and pin the
[Homepage dashboard](../addons/dashboard-homepage/) as the browser start page
for everyone who touches the servers — every service, every host, one page.
