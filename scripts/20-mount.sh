#!/usr/bin/env bash
set -e

# -----------------------------
# Mount LUKS+Btrfs subvolumes + EFI
# -----------------------------

# Unmount / clean any previous mounts
umount -R /mnt 2>/dev/null || true

# Open LUKS mapping (ignore if already open)
cryptsetup open "$ARCH_PART" cryptroot 2>/dev/null || true

# Mount subvolumes
mount -o noatime,compress=zstd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/home /mnt/.snapshots /mnt/boot
mount -o noatime,compress=zstd,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount EFI partition
mount "$EFI_PART" /mnt/boot
