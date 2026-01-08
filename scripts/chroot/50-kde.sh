#!/usr/bin/env bash
set -e

# -----------------------------
# Install KDE Plasma and SDDM
# -----------------------------

# $USERNAME is already exported from 00-prompt.sh
echo "⏱ Installing KDE Plasma Desktop and SDDM..."

# Install KDE Plasma, SDDM (display manager), and useful apps
pacman -Sy --noconfirm \
    plasma plasma-wayland-session kde-applications sddm sddm-kcm

# Enable SDDM display manager
systemctl enable sddm

# Optional: set default target to graphical
systemctl set-default graphical.target

# Set ownership for user home if missing
if [ -d "/home/$USERNAME" ]; then
    chown -R "$USERNAME":"$USERNAME" "/home/$USERNAME"
fi

echo "✅ KDE Plasma and SDDM installed. You can now reboot into GUI."
