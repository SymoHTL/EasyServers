#!/usr/bin/env bash
# Install MicroK8s with sensible add-ons on Ubuntu 22.04/24.04.
# Usage: sudo bash setup.sh [user-to-grant-access]
set -euo pipefail

CHANNEL="1.32/stable"
TARGET_USER="${1:-${SUDO_USER:-$USER}}"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash setup.sh" >&2
  exit 1
fi

if ! command -v snap >/dev/null 2>&1; then
  echo "snapd not found — installing..."
  apt-get update && apt-get install -y snapd
fi

echo "==> Installing MicroK8s (${CHANNEL})"
snap install microk8s --classic --channel="${CHANNEL}"

echo "==> Granting ${TARGET_USER} access to microk8s"
usermod -aG microk8s "${TARGET_USER}"
mkdir -p "/home/${TARGET_USER}/.kube"
chown -R "${TARGET_USER}:${TARGET_USER}" "/home/${TARGET_USER}/.kube" || true

echo "==> Waiting for the cluster to be ready"
microk8s status --wait-ready

echo "==> Enabling add-ons: dns hostpath-storage ingress cert-manager metrics-server"
microk8s enable dns
microk8s enable hostpath-storage
microk8s enable ingress
microk8s enable cert-manager
microk8s enable metrics-server

cat <<EOF

Done. Next steps:
  1. Log out and back in (group change), then: microk8s status --wait-ready
  2. Enable monitoring:                        microk8s enable observability
  3. See README.md for Grafana access and adding nodes.
EOF
