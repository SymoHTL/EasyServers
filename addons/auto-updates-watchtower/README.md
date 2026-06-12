# Add-on — Watchtower: automatic container updates

[Watchtower](https://containrrr.dev/watchtower/) checks your running containers
for new images on a schedule and restarts them with the updated image.

## Should you use it?

| ✅ Good fit | ❌ Bad fit |
|------------|-----------|
| Homelab, low-risk tools (Uptime Kuma, Homepage, dashboards) | Databases & anything with migration steps |
| Containers on rolling tags (`latest`, `lts`, `1`) | Pinned versions you bump deliberately (Path 02!) |
| You read the notifications it sends | Unattended business-critical prod services |

Middle ground: `WATCHTOWER_MONITOR_ONLY=true` — it only *notifies* you that
updates exist, and you apply them yourself.

## Setup

```bash
# optionally edit the schedule / notification URL in docker-compose.yml
docker compose up -d
docker compose logs -f watchtower   # first run report
```

By default this config updates **only containers you explicitly label**:

```yaml
labels:
  - com.centurylinklabs.watchtower.enable=true
```

That's deliberate — opt-in beats "everything updated itself overnight".

## Notifications

Watchtower uses [shoutrrr](https://containrrr.dev/shoutrrr/) URLs — examples:

```
WATCHTOWER_NOTIFICATION_URL: "ntfy://ntfy.sh/your-secret-topic"
WATCHTOWER_NOTIFICATION_URL: "discord://token@webhookid"
WATCHTOWER_NOTIFICATION_URL: "smtp://user:pass@mail.example.com:587/?from=ops@example.com&to=you@example.com"
```
