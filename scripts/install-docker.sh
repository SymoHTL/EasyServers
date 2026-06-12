#!/usr/bin/env bash
# Install Docker Engine + Compose plugin on Ubuntu/Debian via Docker's official
# convenience script, and add the invoking user to the docker group.
# Usage: sudo bash install-docker.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash install-docker.sh" >&2
  exit 1
fi

if command -v docker >/dev/null 2>&1; then
  echo "Docker already installed: $(docker --version)"
else
  echo "==> Installing Docker via get.docker.com"
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
fi

systemctl enable --now docker

REAL_USER="${SUDO_USER:-}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
  usermod -aG docker "$REAL_USER"
  echo "==> Added ${REAL_USER} to the docker group (log out & back in to apply)."
  echo "    Note: docker group membership is root-equivalent — only for trusted admins."
fi

docker --version
docker compose version
echo "Done."
