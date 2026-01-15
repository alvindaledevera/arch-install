#!/usr/bin/env bash
set -e

echo "⏱ Installing optional AUR packages..."

AUR_PKGS=(
    google-chrome
    freedownloadmanager
    upscayl-bin
)

yay -Sy --needed --noconfirm "${AUR_PKGS[@]}"

echo "✅ Optional AUR packages installed"
