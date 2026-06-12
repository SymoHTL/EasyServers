# Add-on — Homepage: one page that shows your whole infrastructure

[Homepage](https://gethomepage.dev/) is a static, fast start page: every
service on every server, grouped and linked, with live status widgets
(Portainer, Grafana, Uptime Kuma, Traefik and ~100 more integrations).

Combined with the [inventory template](../../docs/templates/inventory.md), this
is the "always know what is where" piece: bookmark it as the browser start page
for everyone who touches the servers.

## Setup

```bash
# edit config/services.yaml first — replace the example hosts/URLs with yours
docker compose up -d
# open http://<server>:3080
```

Configuration is just YAML in `config/` — Homepage hot-reloads on save:

- `services.yaml` — your services, grouped (Monitoring / Management / Apps / per-host…)
- `widgets.yaml` — the header row (search box, host resources, datetime)
- `settings.yaml` — title, theme, layout

## Live status widgets

Most tiles can show live data (container state, alert counts, uptime %) by
adding a `widget:` block with an API key — see the
[Homepage widget docs](https://gethomepage.dev/widgets/). The shipped
`services.yaml` contains commented examples for Portainer, Grafana and
Uptime Kuma.

> 🔒 API keys in `config/` are secrets — this folder is for your *private*
> copy. Don't commit real keys/URLs to a public repo, and keep Homepage itself
> on the VPN/LAN ([Traefik `internal-only`](../reverse-proxy-traefik/) middleware).
