#!/usr/bin/env bash

systemctl enable systemd-networkd
systemctl enable systemd-resolved

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF
