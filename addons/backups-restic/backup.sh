#!/usr/bin/env bash
# Restic backup with retention. Configured via /etc/restic/restic.env.
# Logs to syslog (tag: restic-backup), pings HEALTHCHECK_URL on success.
set -euo pipefail

ENV_FILE=/etc/restic/restic.env
# shellcheck source=/dev/null
source "$ENV_FILE"

log() { logger -t restic-backup "$1"; echo "$1"; }

fail() {
  log "BACKUP FAILED: $1"
  exit 1
}

# Run pre-backup hooks (database dumps etc.)
if [[ -d /etc/restic/pre-backup.d ]]; then
  for hook in /etc/restic/pre-backup.d/*; do
    [[ -x "$hook" ]] || continue
    log "pre-backup hook: $hook"
    "$hook" || fail "hook $hook failed"
  done
fi

log "backup starting: ${BACKUP_PATHS}"
# shellcheck disable=SC2086
restic backup $BACKUP_PATHS \
  --exclude-caches \
  ${BACKUP_EXCLUDES:-} \
  --tag scheduled || fail "restic backup returned $?"

log "applying retention policy"
restic forget \
  --keep-daily "${KEEP_DAILY:-7}" \
  --keep-weekly "${KEEP_WEEKLY:-4}" \
  --keep-monthly "${KEEP_MONTHLY:-6}" \
  --prune || fail "restic forget/prune returned $?"

# Periodic integrity check (cheap subset)
restic check --read-data-subset=1% || fail "restic check returned $?"

if [[ -n "${HEALTHCHECK_URL:-}" ]]; then
  curl -fsS -m 10 --retry 3 "$HEALTHCHECK_URL" >/dev/null || log "healthcheck ping failed (backup itself OK)"
fi

log "backup finished OK"
