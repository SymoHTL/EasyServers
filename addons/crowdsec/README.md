# Add-on — CrowdSec: intrusion detection & banning

[CrowdSec](https://www.crowdsec.net/) is a modern fail2ban: it parses logs
(SSH, Traefik/nginx, system) to detect attacks, bans the offenders, and shares
anonymized attack signals with the community — so you also get a constantly
updated blocklist of known-bad IPs in return.

Two parts:

1. **The engine** (this compose file) — detects attacks in your logs.
2. **A bouncer** — actually blocks the IPs. Installed on the **host** so it can
   program the firewall.

## Step 1 — Engine

```bash
docker compose up -d
docker compose exec crowdsec cscli metrics   # log sources being read?
docker compose exec crowdsec cscli decisions list
```

The shipped `acquis.yaml` reads SSH/auth logs and syslog from the host. If you
run the [Traefik add-on](../reverse-proxy-traefik/), its access log (stdout)
can be added via the Docker acquisition — see comments in `acquis.yaml`.

## Step 2 — Firewall bouncer (on the host)

```bash
curl -s https://install.crowdsec.net | sudo sh   # adds the CrowdSec apt repo
sudo apt install crowdsec-firewall-bouncer-iptables

# register the bouncer with the engine:
docker compose exec crowdsec cscli bouncers add firewall-bouncer
# put the printed API key into /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml:
#   api_url: http://127.0.0.1:8080/
#   api_key: <printed key>
sudo systemctl restart crowdsec-firewall-bouncer
```

## How do I know it works?

```bash
# from another machine, fail SSH login a few times, then:
docker compose exec crowdsec cscli decisions list   # your IP shows up banned
# unban yourself:
docker compose exec crowdsec cscli decisions delete --ip <your-ip>
```

Optional: free dashboard at [app.crowdsec.net](https://app.crowdsec.net) —
`cscli console enroll <key>`.
