#!/usr/bin/env bash
set -euo pipefail

ui_banner "Network Configuration"

# -----------------------------
# Hostname setup
# -----------------------------
DEFAULT_HOSTNAME="${DEFAULT_HOSTNAME:-archlinux}"
read -rp "Enter hostname [default: $DEFAULT_HOSTNAME]: " HOSTNAME
HOSTNAME="${HOSTNAME:-$DEFAULT_HOSTNAME}"

ui_info "Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > /etc/hostname

# -----------------------------
# /etc/hosts setup
# -----------------------------
ui_info "Configuring /etc/hosts..."
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# -----------------------------
# Network service setup
# -----------------------------
ui_info "Enabling systemd-networkd and systemd-resolved..."
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# -----------------------------
# Link /etc/resolv.conf safely
# -----------------------------
if [[ ! -L /etc/resolv.conf ]] || [[ "$(readlink /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]]; then
    ui_info "Linking /etc/resolv.conf to systemd stub..."
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
else
    ui_info "/etc/resolv.conf already correctly linked"
fi

ui_success "Network configured successfully"
