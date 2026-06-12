# Add-on — Tailscale: private network for your servers

[Tailscale](https://tailscale.com/) builds a WireGuard mesh VPN between your
devices with ~zero configuration. Every server and laptop gets a stable
`100.x.y.z` address (and a magic DNS name), encrypted end-to-end.

**Why it matters for this repo:** admin UIs (Portainer, Grafana, Beszel,
Prometheus, Homepage…) should never face the public internet. Put them on the
tailnet and bind/firewall them so only VPN clients can reach them.

Free for personal use (up to 100 devices, 3 users). Self-hosted alternative:
[Headscale](https://github.com/juanfont/headscale).

## Setup (per server, 2 minutes)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh        # --ssh enables Tailscale SSH (key mgmt handled for you)
tailscale ip -4                # the server's tailnet address
```

Log in with the printed URL. Repeat on your laptop/phone (apps for everything).

For servers, disable key expiry in the admin console
(machine → … → *Disable key expiry*) so they don't drop off after 180 days.

## Locking admin UIs to the tailnet

Option A — bind services to the tailscale IP in compose:

```yaml
ports:
  - "100.64.0.10:3000:3000"   # Grafana only reachable via VPN
```

Option B — keep `127.0.0.1:` bindings and use `tailscale serve` to expose them
on the tailnet with automatic HTTPS:

```bash
sudo tailscale serve --bg --https=443 http://127.0.0.1:3000
```

Option C — ufw: allow the ports only on the tailscale interface:

```bash
sudo ufw allow in on tailscale0 to any port 3000,9443,8090 proto tcp
```

## ACLs (companies)

In the admin console, restrict who reaches what — e.g. only the `ops` group
may reach servers on ports 22/3000/9443. Start simple; the default
"everyone sees everything" is fine for a solo admin and wrong for a team.
