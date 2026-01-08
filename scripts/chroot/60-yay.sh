#!/usr/bin/env bash
set -e

# -----------------------------
# 60-yay.sh - Install yay (AUR helper) with dependencies
# -----------------------------

# $USERNAME ay dapat exported mula sa 00-prompt.sh o 45-user.sh
if [ -z "$USERNAME" ]; then
    echo "❌ USERNAME variable not set. Exiting."
    exit 1
fi

echo "⏱ Installing dependencies for yay..."
# Install required packages
pacman -Sy --needed --noconfirm git base-devel

echo "⏱ Installing yay for user $USERNAME..."
# Switch to the new user to install yay in their home
runuser -l "$USERNAME" -c "
    cd ~
    # Skip cloning if yay already exists
    if [ ! -d ~/yay ]; then
        git clone https://aur.archlinux.org/yay.git
    fi
    cd yay
    makepkg -si --noconfirm
"

echo "✅ yay installed for user $USERNAME"
