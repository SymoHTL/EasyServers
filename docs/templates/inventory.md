# Server inventory

> Copy this file into your (private!) internal wiki or repo. Update it whenever a
> server or service is added, moved or retired. Review quarterly.
> Public IPs, credentials and secrets do **not** belong in a public repo.

Last reviewed: YYYY-MM-DD by NAME

## Hosts

| Hostname | IP (LAN / VPN) | Provider / Location | OS | Role | Owner | Monitored | Backed up |
|----------|----------------|---------------------|----|------|-------|-----------|-----------|
| web-01 | 10.0.0.11 / 100.64.0.11 | Hetzner FSN1 | Ubuntu 24.04 | Reverse proxy + apps | Alice | ✅ Beszel | ✅ restic → S3, daily |
| db-01 | 10.0.0.12 / 100.64.0.12 | Office rack U7 | Debian 12 | PostgreSQL | Bob | ✅ Beszel | ✅ restic + pg_dump |
| nas-01 | 10.0.0.20 / 100.64.0.20 | Office rack U9 | TrueNAS | Storage, backup target | Bob | ✅ Uptime Kuma | n/a (is the target) |

## Services

| Service | URL | Host | Port(s) | Data location | Exposed to | Notes |
|---------|-----|------|---------|---------------|------------|-------|
| Grafana | https://grafana.internal.example.com | web-01 | 3000 (via Traefik) | volume `grafana-data` | VPN only | admin 2FA on |
| Portainer | https://portainer.internal.example.com | web-01 | 9443 | volume `portainer_data` | VPN only | |
| Customer app | https://app.example.com | web-01 | 8080 (via Traefik) | `/srv/app/data` | Public | |

## Credentials & escalation

| What | Where stored | Who has access |
|------|--------------|----------------|
| SSH keys | Each admin's hardware key / password manager | Alice, Bob |
| .env secrets | Vaultwarden → "Infra" collection | Alice, Bob |
| Escalation | Alice → Bob → hosting provider support | |
