#!/usr/bin/env bash
set -e

# VM / ISO safe writable tmp
mkdir -p /mnt/tmp
mount -t tmpfs tmpfs /mnt/tmp
mount --bind /mnt/tmp /tmp

# Install packages
pacstrap /mnt base linux linux-firmware btrfs-progs vim sudo git \
nano timeshift zram-generator

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
