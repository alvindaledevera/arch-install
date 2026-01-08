#!/usr/bin/env bash
set -e

# -----------------------------
# 60-yay.sh - Install yay from AUR
# -----------------------------

# $USERNAME must be exported from 00-prompt.sh or 45-user.sh
if [ -z "$USERNAME" ]; then
    echo "❌ USERNAME variable not set. Exiting."
    exit 1
fi

echo "⏱ Installing dependencies for building AUR packages..."
# Install required packages
pacman -Sy --needed --noconfirm git base-devel

echo "⏱ Installing yay for user $USERNAME..."
# Run the installation as the new user
runuser -l "$USERNAME" -c '
    set -e
    cd ~
    # Skip cloning if yay already exists
    if [ ! -d ~/yay ]; then
        git clone https://aur.archlinux.org/yay.git
    fi
    cd yay
    # Build and install yay without prompts
    makepkg -si --noconfirm
'

echo "✅ yay installed for user $USERNAME"
