# Ready-made Traefik overrides for the EasyServers paths

Compose *override files* add Traefik labels to a stack **without editing the
original compose file** — updates from this repo stay merge-free.

Usage pattern (example: Uptime Kuma from Path 01):

```bash
cd paths/01-starter/uptime-kuma
cp ../../../addons/reverse-proxy-traefik/examples/starter-uptime-kuma.override.yml ./
# edit the Host(`...`) rule to your domain, then:
docker compose -f docker-compose.yml -f starter-uptime-kuma.override.yml up -d
```

| File | Exposes | Default protection |
|------|---------|--------------------|
| `starter-portainer.override.yml` | Portainer UI | `internal-only@file` (LAN/VPN) |
| `starter-beszel.override.yml` | Beszel hub | `internal-only@file` |
| `starter-uptime-kuma.override.yml` | Uptime Kuma | `internal-only@file` — remove it if you serve a public status page |
| `observability-grafana.override.yml` | Grafana (Path 02) | `internal-only@file` |
| `dashboard-homepage.override.yml` | Homepage | `internal-only@file` |

All overrides:

- attach the service to the external `proxy` network (create once: `docker network create proxy`)
- use `ports: !reset []` so the UI is **only** reachable through Traefik
  (needs Docker Compose ≥ 2.24 — older: delete that line and bind the port to
  `127.0.0.1:` in the original file instead)
- attach the `internal-only@file` middleware from
  [`../dynamic/middlewares.yml`](../dynamic/middlewares.yml) — admin UIs stay
  off the public internet even with valid public DNS. Adjust the allowed
  ranges there to your LAN/VPN.

DNS: point the hostnames (e.g. `grafana.example.com`) at the Traefik server —
individual records or one wildcard `*.example.com`. For wildcard **certificates**
see the DNS-challenge section in [`../traefik.yml`](../traefik.yml).
