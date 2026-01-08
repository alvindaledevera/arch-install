#!/usr/bin/env bash
set -e

# Enable networking services
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Only create symlink if it doesn't exist or points somewhere else
if [ "$(readlink -f /etc/resolv.conf)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi

# Create basic DHCP config for wired interfaces
cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF
