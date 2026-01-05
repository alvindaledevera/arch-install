#!/usr/bin/env bash

# Ensure writable tmp
mkdir -p /mnt/tmp
mount --bind /mnt/tmp /tmp

pacstrap /mnt base linux linux-firmware btrfs-progs vim sudo git \
nano timeshift zram-generator

genfstab -U /mnt >> /mnt/etc/fstab
