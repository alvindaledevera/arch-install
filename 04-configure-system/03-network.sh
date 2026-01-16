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
# Enable systemd-networkd and systemd-resolved
ui_info "Enabling systemd-networkd and systemd-resolved..."
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Link resolv.conf
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

ui_success "Network configured successfully"
