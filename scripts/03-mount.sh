#!/usr/bin/env bash
set -e

# -----------------------------
# Mount LUKS + Btrfs subvolumes + EFI
# Performance tuned + Timeshift
# -----------------------------

# Unmount / clean any previous mounts
umount -R /mnt 2>/dev/null || true

# Open LUKS mapping (ignore if already open)
cryptsetup open "$ARCH_PART" cryptroot 2>/dev/null || true

# Common Btrfs mount options
BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120"

# Mount root subvolume
mount -o $BTRFS_OPTS,subvol=@ /dev/mapper/cryptroot /mnt

# Create mount points
mkdir -p /mnt/home /mnt/.snapshots /mnt/boot

# Mount home subvolume
mount -o $BTRFS_OPTS,subvol=@home /dev/mapper/cryptroot /mnt/home

# Mount snapshots subvolume (for Timeshift)
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount EFI partition
mount "$EFI_PART" /mnt/boot
