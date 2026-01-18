#!/usr/bin/env bash
set -euo pipefail

ui_banner "User Setup"

# -----------------------------
# Root password
# -----------------------------
ui_section "Set root password"
echo "Please enter the root password:"
passwd root

# # -----------------------------
# # Create regular user
# # -----------------------------
# read -rp "Enter your username: " USERNAME

# ui_info "Creating user: $USERNAME"
# useradd -m -G wheel -s /bin/bash "$USERNAME"

# # -----------------------------
# # Set user password
# # -----------------------------
# ui_section "Set password for $USERNAME"
# echo "Please enter password for user $USERNAME:"
# passwd "$USERNAME"

# # -----------------------------
# # Sudo setup (wheel group)
# # -----------------------------
# ui_info "Ensuring wheel group has sudo privileges"
# if ! grep -q "^%wheel" /etc/sudoers; then
#     echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
# fi

# ui_success "User $USERNAME created and configured successfully"
