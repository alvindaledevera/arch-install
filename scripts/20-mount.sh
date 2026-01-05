#!/usr/bin/env bash
set -e

# -----------------------------
# 20-mount.sh
# -----------------------------

# Make sure /mnt is clean
umount -R /mnt 2>/dev/null || true

# Make writable tmp for VM/ISO
mkdir -p /mnt/tmp
mountpoint -q /mnt/tmp || mount --bind /mnt/tmp /tmp

# Ensure cryptroot is open
if ! cryptsetup status cryptroot >/dev/null 2>&1; then
    cryptsetup open "$ARCH_PART" cryptroot
fi

# Make sure Btrfs subvolumes exist before mounting
for subvol in @ @home @snapshots; do
    if ! btrfs subvolume list /dev/mapper/cryptroot | grep -q "$subvol"; then
        echo "✨ Creating missing Btrfs subvolume: $subvol"
        mount /dev/mapper/cryptroot /mnt
        btrfs subvolume create "/mnt/$subvol"
        umount /mnt
    fi
done

# Mount subvolumes
mount -o noatime,compress=zstd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/home /mnt/.snapshots /mnt/boot
mount -o noatime,compress=zstd,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount EFI
mount "$EFI_PART" /mnt/boot
