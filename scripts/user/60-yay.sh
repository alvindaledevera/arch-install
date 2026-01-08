#!/usr/bin/env bash
set -e

cd ~

if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi
