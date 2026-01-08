#!/usr/bin/env bash
set -e

# Install packages
pacstrap /mnt base linux linux-firmware btrfs-progs vim sudo git \
nano timeshift zram-generator

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
