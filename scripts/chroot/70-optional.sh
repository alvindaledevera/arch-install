#!/usr/bin/env bash
set -e

# -----------------------------
# 70-optional.sh - Install optional packages
# -----------------------------

# $USERNAME should already be exported
if [ -z "$USERNAME" ]; then
    echo "❌ USERNAME variable not set. Exiting."
    exit 1
fi

echo "⏱ Installing optional packages..."

# Pacman packages
PACMAN_PKGS=(
    nano
    firefox
    vlc
    htop
    code
    fastfetch
)

# Install official repo packages
pacman -Sy --needed --noconfirm "${PACMAN_PKGS[@]}"

# AUR packages via yay
AUR_PKGS=(
    google-chrome
    # add more AUR packages here
)

# Install AUR packages as the user
runuser -l "$USERNAME" -c "
    yay -Sy --needed --noconfirm ${AUR_PKGS[*]}
"

echo "✅ Optional programs installed"
