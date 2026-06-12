# Add-on — Traefik reverse proxy with automatic HTTPS

One entry point (ports 80/443) for all your web UIs and apps, with automatic
Let's Encrypt certificates. Services are exposed by adding a few labels to
their compose file — no central config edits.

## Prerequisites

- A domain (or subdomains) pointing at this server, e.g. `*.example.com`
- Ports 80 and 443 open: `sudo ufw allow 80,443/tcp`

## Setup

```bash
# 1. edit traefik.yml — set your Let's Encrypt email (and your domain in docker-compose.yml)
docker network create proxy
docker compose up -d
```

## Exposing a service

Add the service to the `proxy` network and label it. Example — Grafana from
[Path 02](../../paths/02-observability/):

```yaml
services:
  grafana:
    # ... existing config, REMOVE the ports: section ...
    networks: [default, proxy]
    labels:
      - traefik.enable=true
      - traefik.http.routers.grafana.rule=Host(`grafana.example.com`)
      - traefik.http.routers.grafana.entrypoints=websecure
      - traefik.http.routers.grafana.tls.certresolver=letsencrypt
      - traefik.http.services.grafana.loadbalancer.server.port=3000

networks:
  proxy:
    external: true
```

`docker compose up -d` — Traefik picks it up live and fetches a certificate
within seconds.

## Protecting admin UIs

`dynamic/middlewares.yml` ships two ready-made middlewares:

- **`internal-only`** — allow only LAN/VPN address ranges. Attach with:
  `traefik.http.routers.grafana.middlewares=internal-only@file`
- **`basic-auth`** — username/password in front of services without their own
  login. Generate the hash: `htpasswd -nB admin` (escape `$` as `$$` in compose labels,
  not needed in the yml file).

## How do I know it works?

- `https://whoami.example.com` (demo service in the compose file) returns
  request info with a valid certificate.
- Dashboard: `docker compose exec traefik traefik version` and
  `http://127.0.0.1:8080` via SSH tunnel (API is bound to localhost).

When everything works, delete the `whoami` service.
