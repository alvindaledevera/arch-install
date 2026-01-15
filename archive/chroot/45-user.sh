#!/usr/bin/env bash
set -e

# -----------------------------
# Create user and configure sudo
# -----------------------------

# $USERNAME is already exported from 00-prompt.sh
useradd -m -G wheel "$USERNAME"

# Function to safely set password
set_password() {
    local user=$1
    while true; do
        echo "Set password for $user:"
        passwd "$user" && break
        echo "❌ Passwords do not match, try again."
    done
}

# Set password for the new user
set_password "$USERNAME"

# Set root password
set_password root

# Enable wheel group for sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Copy user scripts
cp -r /root/arch-install/scripts/user /home/$USERNAME/

# Fix ownership & permissions
chown -R $USERNAME:$USERNAME /home/$USERNAME/user
chmod +x /home/$USERNAME/user/*.sh

echo "✅ User $USERNAME created and sudo configured"
