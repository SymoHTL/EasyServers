# Add-on — Restic backups

[Restic](https://restic.net/) makes encrypted, deduplicated, incremental
backups to almost anywhere: another disk, SFTP, S3, Backblaze B2, Hetzner
Storage Box, …. This add-on gives you a backup script with retention policy
and a systemd timer.

**Rule of thumb (3-2-1):** 3 copies, 2 different media, 1 offsite.
**A backup you never restored is not a backup** — test restores quarterly.

## Setup

```bash
sudo apt install restic

sudo mkdir -p /etc/restic
sudo cp restic.env.example /etc/restic/restic.env
sudo chmod 600 /etc/restic/restic.env
sudo nano /etc/restic/restic.env      # repository, password, what to back up

sudo cp backup.sh /usr/local/bin/restic-backup.sh
sudo chmod +x /usr/local/bin/restic-backup.sh

# initialize the repository (first time only):
sudo bash -c 'source /etc/restic/restic.env && restic init'

# first backup, manually:
sudo /usr/local/bin/restic-backup.sh
```

> ⚠️ **Store the restic password somewhere safe outside the server**
> (password manager). Without it, your backups are unrecoverable garbage.

## Schedule with systemd

```bash
sudo cp restic-backup.service restic-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now restic-backup.timer
systemctl list-timers restic-backup.timer    # next run time
```

## Backing up Docker volumes

Named volumes live in `/var/lib/docker/volumes` — already included in the
example `BACKUP_PATHS`. Databases should additionally be dumped before backup
(consistent snapshot), e.g. in `/etc/restic/pre-backup.d/`:

```bash
docker exec postgres pg_dumpall -U postgres > /srv/backups/postgres.sql
```

The backup script runs every executable in `/etc/restic/pre-backup.d/` first.

## Restore

```bash
source /etc/restic/restic.env
restic snapshots                       # list
restic restore latest --target /tmp/restore --include /srv/app
```

## Monitoring your backups

The script logs to syslog (→ Loki in Path 02) and exits non-zero on failure.
Easy alerting: create a "push" monitor in Uptime Kuma and set its URL as
`HEALTHCHECK_URL` in `restic.env` — you'll be alerted when backups *stop*
happening, which is exactly the failure mode people miss.
