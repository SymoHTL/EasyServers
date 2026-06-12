# Path 01 — Starter: Portainer + Beszel + Uptime Kuma

The fastest way to go from "I have some servers" to "I can see all my servers,
manage their containers and get alerted when something breaks". Three small
tools, all with friendly web UIs, all configured in minutes.

| Tool | Job | UI port |
|------|-----|---------|
| **Portainer CE** | Manage Docker containers, stacks, images, volumes via web UI | `9443` (HTTPS) |
| **Beszel** | Server monitoring: CPU, RAM, disk, network, temperature, Docker stats, alerts | `8090` |
| **Uptime Kuma** | External checks: is my website/API/port up? Status pages, notifications | `3001` |

**Architecture:** one server acts as the *hub* (runs all three UIs). Every server
you want to monitor (including the hub itself) runs the tiny *Beszel agent* and
optionally a *Portainer agent*.

## Prerequisites

- Ubuntu/Debian server(s) with the [security baseline](../../docs/security-baseline.md) applied
- Docker + Compose plugin: `sudo bash scripts/install-docker.sh` (from repo root)

## Step 1 — Hub server

```bash
docker compose -f portainer/docker-compose.yml up -d
docker compose -f beszel/hub/docker-compose.yml up -d
docker compose -f uptime-kuma/docker-compose.yml up -d
```

Then, **within a few minutes** (Portainer locks itself if you wait too long):

1. Open `https://<hub-ip>:9443` → create the Portainer admin account (self-signed cert warning is expected).
2. Open `http://<hub-ip>:8090` → create the Beszel admin account.
3. Open `http://<hub-ip>:3001` → create the Uptime Kuma admin account.

> 🔒 These UIs should only be reachable from your LAN or VPN — see
> [Tailscale add-on](../../addons/vpn-tailscale/) — or behind the
> [Traefik add-on](../../addons/reverse-proxy-traefik/) with HTTPS.

## Step 2 — Add servers to Beszel

On the hub UI: **Add system** → enter the server's name and IP. Beszel shows you
the agent's `KEY` (and a ready-made compose snippet).

On each monitored server:

```bash
cd beszel/agent
cp .env.example .env     # paste the KEY from the hub UI
docker compose up -d
```

The agent listens on port `45876` — allow it from the hub only:
`sudo ufw allow from <hub-ip> to any port 45876 proto tcp`

Now set up alerts: click a system → bell icon → thresholds for CPU/RAM/disk;
**Settings → Notifications** for email/Discord/Telegram/ntfy.

## Step 3 — Add checks to Uptime Kuma

**Add New Monitor** for every website, API and service you care about —
HTTP(s), TCP port, ping, DNS, even Docker containers. Then
**Settings → Notifications** to wire up email/chat, and optionally create a
public **status page**.

## Step 4 (optional) — Manage remote servers' containers in Portainer

On each remote server, run the Portainer agent:

```bash
docker compose -f portainer/agent.docker-compose.yml up -d
sudo ufw allow from <hub-ip> to any port 9001 proto tcp
```

Then in the Portainer UI: **Environments → Add environment → Docker (agent)** → `tcp://<server-ip>:9001`.

## How do I know it works?

- Beszel shows live graphs for every system, and a test alert arrives.
- Uptime Kuma shows green checks; stop a test container and watch the alert fire.
- Portainer lists containers on every environment.

## Updating

```bash
docker compose -f <file> pull && docker compose -f <file> up -d
```

or use the [Watchtower add-on](../../addons/auto-updates-watchtower/).

## Data locations

Named Docker volumes: `portainer_data`, `beszel_data`, `uptime-kuma`.
Back them up with the [Restic add-on](../../addons/backups-restic/).
