#!/usr/bin/env bash
set -e

print_stage "$0"

echo "⏱ Updating pacman mirrors and enabling parallel downloads..."

# Install reflector if missing
pacman -Sy --noconfirm reflector

# Update mirrorlist with fastest HTTPS mirrors
reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Enable parallel downloads
sed -i 's/^#ParallelDownloads/ParallelDownloads = 5/' /etc/pacman.conf

echo "✅ Mirrors updated and parallel downloads enabled"
