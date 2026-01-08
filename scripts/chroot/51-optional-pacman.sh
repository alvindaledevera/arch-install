#!/usr/bin/env bash
set -e

echo "⏱ Installing optional pacman packages..."

PACMAN_PKGS=(
    nano
    htop
    code
    fastfetch
)

pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"

echo "✅ Optional pacman packages installed"
