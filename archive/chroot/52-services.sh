#!/usr/bin/env bash
set -e

echo "⏱ Enabling system services..."

# Network
systemctl enable NetworkManager

# Bluetooth
systemctl enable bluetooth

# Display Manager (KDE)
systemctl enable sddm

# Time sync
systemctl enable systemd-timesyncd

# Power management (laptop)
if pacman -Q tlp &>/dev/null; then
    systemctl enable tlp
    systemctl mask systemd-rfkill.service
    systemctl mask systemd-rfkill.socket
fi

# Optional: zram (kung meron ka sa 44-zram.sh)
if systemctl list-unit-files | grep -q zram; then
    systemctl enable zram
fi

echo "✅ Services enabled"
