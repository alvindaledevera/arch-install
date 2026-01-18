#!/usr/bin/env bash
set -euo pipefail

ui_banner "Network Configuration"

# -------------------------------------------------
# Load vars.conf (inside chroot)
# -------------------------------------------------
VARS_FILE="/root/arch-install/vars.conf"
if [[ -f "$VARS_FILE" ]]; then
    source "$VARS_FILE"
else
    ui_warn "vars.conf not found inside chroot"
fi

# -------------------------------------------------
# Hostname
# -------------------------------------------------
DEFAULT_HOSTNAME="${HOSTNAME:-archlinux}"

if [[ -n "${HOSTNAME:-}" ]]; then
    ui_info "Using hostname from vars.conf: $HOSTNAME"
else
    ui_step "Hostname setup"
    read -rp "Enter hostname [default: $DEFAULT_HOSTNAME]: " HOSTNAME
    HOSTNAME="${HOSTNAME:-$DEFAULT_HOSTNAME}"
fi

ui_info "Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > /etc/hostname

# -------------------------------------------------
# /etc/hosts
# -------------------------------------------------
ui_info "Configuring /etc/hosts"
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# -------------------------------------------------
# Enable networking services
# -------------------------------------------------
ui_info "Enabling systemd-networkd & systemd-resolved"
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# -------------------------------------------------
# resolv.conf (idempotent)
# -------------------------------------------------
if [[ ! -L /etc/resolv.conf ]]; then
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

# -------------------------------------------------
# Basic DHCP for wired interfaces
# -------------------------------------------------
NETWORK_DIR="/etc/systemd/network"
mkdir -p "$NETWORK_DIR"

cat > "$NETWORK_DIR/20-wired.network" <<EOF
[Match]
Name=en*

[Network]
DHCP=yes
EOF

ui_success "Network configuration completed"
