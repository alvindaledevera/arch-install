#!/usr/bin/env bash
set -e

# Enable networking services (safe in chroot)
systemctl enable systemd-networkd || true
systemctl enable systemd-resolved || true

# Create symlink for resolv.conf (ignore harmless error)
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true

# Basic DHCP config for wired interfaces
cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF
