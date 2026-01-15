#!/usr/bin/env bash
set -e

echo "⏱ Installing base system..."
# Minimal base install
pacstrap /mnt base linux linux-firmware btrfs-progs base-devel linux-headers

echo "⏱ Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "✅ Base system installed."
