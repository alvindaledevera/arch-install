#!/usr/bin/env bash
set -euo pipefail

ui_banner "User Setup"

# -----------------------------
# Root password
# -----------------------------
ui_info "Setting root password"
echo "root:${ROOT_PASSWORD}" | chpasswd

# -----------------------------
# User creation
# -----------------------------
if ! id "$USERNAME" &>/dev/null; then
    ui_info "Creating user $USERNAME"
    useradd -m -G wheel "$USERNAME"
fi

ui_info "Setting password for $USERNAME"
echo "${USERNAME}:${USER_PASSWORD}" | chpasswd

# -----------------------------
# Sudo access
# -----------------------------
ui_info "Enabling sudo for wheel group"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

ui_success "Users configured successfully"
