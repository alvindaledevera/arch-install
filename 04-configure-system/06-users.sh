#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Load UI helpers
# -----------------------------
source /root/arch-install/lib/ui.sh

# -----------------------------
# UI banner
# -----------------------------
ui_banner "User Setup"

# -----------------------------
# Ask for username
# -----------------------------
read -rp "Enter username for new user: " USERNAME

# -----------------------------
# Root password
# -----------------------------
while true; do
    read -s -p "Password for root: " ROOT_PASSWORD
    echo
    read -s -p "Confirm root password: " ROOT_CONFIRM
    echo
    [[ "$ROOT_PASSWORD" == "$ROOT_CONFIRM" ]] && break
    echo "❌ Passwords do not match, try again."
done

# -----------------------------
# User password
# -----------------------------
while true; do
    read -s -p "Password for $USERNAME: " USER_PASSWORD
    echo
    read -s -p "Confirm password: " USER_CONFIRM
    echo
    [[ "$USER_PASSWORD" == "$USER_CONFIRM" ]] && break
    echo "❌ Passwords do not match, try again."
done

# -----------------------------
# Set root password
# -----------------------------
ui_info "Setting root password..."
echo "root:$ROOT_PASSWORD" | chpasswd

# -----------------------------
# Create user if it doesn't exist
# -----------------------------
if ! id "$USERNAME" &>/dev/null; then
    ui_info "Creating user $USERNAME..."
    useradd -m -G wheel "$USERNAME"
fi

# -----------------------------
# Set user password
# -----------------------------
ui_info "Setting password for $USERNAME..."
echo "$USERNAME:$USER_PASSWORD" | chpasswd

# -----------------------------
# Enable sudo for wheel group
# -----------------------------
ui_info "Enabling sudo for wheel group..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# -----------------------------
# Done
# -----------------------------
ui_success "Users configured successfully ✅"
