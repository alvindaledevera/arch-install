#!/usr/bin/env bash

# Make sure /mnt is clean
umount -R /mnt 2>/dev/null || true

# Bind writable tmp for VM / ISO
mkdir -p /mnt/tmp
mount --bind /mnt/tmp /tmp

# Mount subvolumes
mount -o noatime,compress=zstd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot /mnt/home /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount EFI
mount "$EFI_PART" /mnt/boot
