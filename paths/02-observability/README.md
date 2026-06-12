# Path 02 — Observability: Prometheus + Grafana + Loki + Alertmanager

The industry-standard open-source observability stack. One *monitoring server*
runs the stack; every monitored host runs two tiny exporters. You get:

- **Metrics** (Prometheus): CPU, RAM, disk, network, per-container stats, anything with an exporter
- **Dashboards** (Grafana): provisioned datasources, import world-class community dashboards in two clicks
- **Logs** (Loki + Alloy): all container logs and syslog, centrally searchable with LogQL
- **Alerts** (Alertmanager): host down, disk filling up, CPU pegged — routed to email/Slack/ntfy/…

```
 monitored host A ── node-exporter + cAdvisor ──┐  (metrics, pulled)
 monitored host B ── node-exporter + cAdvisor ──┼──► Prometheus ──► Alertmanager ──► you
                                                │        │
 monitoring server ── Alloy (logs, pushed) ──► Loki      └──► Grafana ◄── Loki
```

## Prerequisites

- A monitoring server (2 vCPU / 4 GB RAM is plenty for ~20 hosts) with Docker installed
- [Security baseline](../../docs/security-baseline.md) applied everywhere

## Step 1 — Start the stack on the monitoring server

```bash
cd paths/02-observability
cp .env.example .env          # set the Grafana admin password!
docker compose up -d
```

| UI | Address | Notes |
|----|---------|-------|
| Grafana | `http://<server>:3000` | login `admin` / your `.env` password |
| Prometheus | `http://127.0.0.1:9090` | bound to localhost — tunnel: `ssh -L 9090:localhost:9090 <server>` |
| Alertmanager | `http://127.0.0.1:9093` | bound to localhost, same trick |

Grafana already has Prometheus and Loki configured as datasources (provisioned
from `grafana/provisioning/`). Logs of all containers on the monitoring server
flow into Loki via Alloy automatically — check **Explore → Loki**.

## Step 2 — Add monitored hosts

On **each** host you want metrics from:

```bash
# copy the agents/ folder to the host, then:
cd agents && docker compose up -d
# node-exporter :9100 and cAdvisor :8085 — restrict to the monitoring server:
sudo ufw allow from <monitoring-ip> to any port 9100,8085 proto tcp
```

On the **monitoring server**, register the host by adding it to
`prometheus/targets/nodes.yml` and `prometheus/targets/cadvisor.yml`
(file-based service discovery — no restart needed, Prometheus picks it up
within a minute). Verify under `http://127.0.0.1:9090/targets`.

## Step 3 — Dashboards

In Grafana: **Dashboards → New → Import** and enter an ID:

| ID | Dashboard |
|----|-----------|
| `1860` | Node Exporter Full (the classic host dashboard) |
| `19792` | cAdvisor Docker container metrics |
| `13639` | Loki logs / app overview |

Pick **Prometheus** (or Loki) as the datasource when asked. Done.

## Step 4 — Alerts

Sensible default rules ship in `prometheus/rules/alerts.yml`:
host down, high CPU (10 min), memory < 10 %, disk < 10 % and disk-full
prediction. Test them: stop a node-exporter and watch `http://127.0.0.1:9090/alerts`.

To actually *receive* alerts, edit `alertmanager/alertmanager.yml` — it contains
commented-out, ready-to-fill examples for **email (SMTP)** and **ntfy.sh push
notifications**, then `docker compose restart alertmanager`.

## Shipping logs from other hosts (optional)

Run Alloy on each host too: copy `alloy/` there, change `LOKI_URL` in its
compose file to `http://<monitoring-ip>:3100`, and open port 3100 on the
monitoring server *only* for your hosts' IPs (or better: a VPN). For a small
fleet, container logs from the monitoring server plus metrics from everywhere
is a perfectly fine start.

## Updating

Versions are pinned in `docker-compose.yml`. Read the release notes
(Grafana and Loki occasionally have breaking changes), bump the tags, then
`docker compose pull && docker compose up -d`.

## Data locations

Named volumes: `prometheus-data` (metrics, 30 d retention), `loki-data`
(logs, 30 d retention), `grafana-data` (dashboards, users). Back them up with
the [Restic add-on](../../addons/backups-restic/).
