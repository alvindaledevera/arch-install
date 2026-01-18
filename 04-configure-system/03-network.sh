#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# UI banner
# -----------------------------
if type ui_banner &>/dev/null; then
    ui_banner "Network Configuration"
fi

# -----------------------------
# Hostname setup
# -----------------------------
DEFAULT_HOSTNAME="${DEFAULT_HOSTNAME:-archlinux}"
if type ui_info &>/dev/null; then
    ui_info "Default hostname: $DEFAULT_HOSTNAME"
fi
read -rp "Enter hostname [default: $DEFAULT_HOSTNAME]: " HOSTNAME
HOSTNAME="${HOSTNAME:-$DEFAULT_HOSTNAME}"

if type ui_info &>/dev/null; then
    ui_info "Setting hostname to $HOSTNAME"
fi
echo "$HOSTNAME" > /etc/hostname

# -----------------------------
# /etc/hosts setup
# -----------------------------
if type ui_info &>/dev/null; then
    ui_info "Configuring /etc/hosts..."
fi
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# -----------------------------
# Enable networking services (safe in chroot)
# -----------------------------
if type ui_info &>/dev/null; then
    ui_info "Enabling systemd-networkd and systemd-resolved..."
fi
systemctl enable systemd-networkd || true
systemctl enable systemd-resolved || true

# -----------------------------
# Create symlink for resolv.conf (ignore harmless error)
# -----------------------------
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true

# -----------------------------
# Basic DHCP config for wired interfaces
# -----------------------------
cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

if type ui_success &>/dev/null; then
    ui_success "Network configured successfully"
fi
