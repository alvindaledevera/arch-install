#!/usr/bin/env bash
set -e

# Unmount / clean
umount -R /mnt 2>/dev/null || true

# Ensure cryptroot is open
cryptsetup open "$ARCH_PART" cryptroot 2>/dev/null || true

# Mount subvolumes
mount -o noatime,compress=zstd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/home /mnt/.snapshots /mnt/boot
mount -o noatime,compress=zstd,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount EFI
mount "$EFI_PART" /mnt/boot

# Bind /tmp for VM safe pacstrap
mkdir -p /mnt/tmp
mount --bind /mnt/tmp /tmp
