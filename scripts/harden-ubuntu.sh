#!/usr/bin/env bash
# EasyServers security baseline for Ubuntu 22.04/24.04 & Debian 12:
#   - ufw firewall (default deny incoming, SSH allowed)
#   - fail2ban for SSH brute-force protection
#   - unattended security updates
#   - SSH hardening (no root login; password auth disabled ONLY if the
#     invoking user has an authorized_keys entry — no lockouts)
#
# Usage: sudo bash harden-ubuntu.sh [--yes] [--ssh-port 22]
set -euo pipefail

ASSUME_YES=0
SSH_PORT=22
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) ASSUME_YES=1; shift ;;
    --ssh-port) SSH_PORT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash harden-ubuntu.sh" >&2
  exit 1
fi

confirm() {
  [[ $ASSUME_YES -eq 1 ]] && return 0
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

REAL_USER="${SUDO_USER:-root}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

echo "==> Installing packages (ufw, fail2ban, unattended-upgrades)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq ufw fail2ban unattended-upgrades apt-listchanges

echo "==> Configuring firewall (default deny incoming, allow SSH on ${SSH_PORT})"
ufw default deny incoming
ufw default allow outgoing
ufw allow "${SSH_PORT}/tcp" comment "SSH"
ufw --force enable
echo "    NOTE: Docker published ports bypass ufw. Bind internal services to"
echo "    127.0.0.1 (e.g. '127.0.0.1:9090:9090') or use a VPN/reverse proxy."

echo "==> Enabling fail2ban (sshd jail)"
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = ${SSH_PORT}
maxretry = 5
bantime = 1h
findtime = 10m
EOF
systemctl enable --now fail2ban
systemctl restart fail2ban

echo "==> Enabling unattended security updates"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
systemctl enable --now unattended-upgrades 2>/dev/null || true

echo "==> Hardening SSH"
SSHD_DROPIN=/etc/ssh/sshd_config.d/90-easyservers.conf
{
  echo "PermitRootLogin no"
  echo "MaxAuthTries 4"
  echo "X11Forwarding no"
} > "$SSHD_DROPIN"

# Only disable password auth if we can prove key-based login is possible.
if [[ -s "${REAL_HOME}/.ssh/authorized_keys" ]]; then
  echo "    Found authorized_keys for ${REAL_USER}."
  if confirm "    Disable SSH password authentication (keys only)?"; then
    echo "PasswordAuthentication no" >> "$SSHD_DROPIN"
    echo "    Password authentication disabled."
  fi
else
  echo "    WARNING: no authorized_keys for ${REAL_USER} — keeping password auth ON."
  echo "    Add your key (ssh-copy-id ${REAL_USER}@this-host) and re-run."
fi

if sshd -t; then
  systemctl reload ssh 2>/dev/null || systemctl reload sshd
else
  echo "sshd config test failed — removing drop-in, SSH left unchanged." >&2
  rm -f "$SSHD_DROPIN"
  exit 1
fi

echo
echo "==> Done. Summary:"
ufw status verbose | sed 's/^/    /'
echo "    fail2ban: $(fail2ban-client status sshd 2>/dev/null | grep 'Currently banned' || echo active)"
echo
echo "IMPORTANT: keep this session open and verify you can SSH in from a NEW terminal."
