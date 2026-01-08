#!/usr/bin/env bash
set -e

# Enable networking services
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Create symlink for resolv.conf (suppress harmless warning)
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null

# Basic DHCP config for wired interfaces
cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF
