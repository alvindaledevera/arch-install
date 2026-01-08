#!/usr/bin/env bash
set -e

# -----------------------------
# Create user and configure sudo
# -----------------------------

# $USERNAME is already exported from 00-prompt.sh
useradd -m -G wheel "$USERNAME"

# Set password for the new user
echo "Set password for user $USERNAME:"
passwd "$USERNAME"

# Set root password
echo "Set password for root:"
passwd

# Enable wheel group for sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "✅ User $USERNAME created and sudo configured"
