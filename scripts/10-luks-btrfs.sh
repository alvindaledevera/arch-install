#!/usr/bin/env bash
set -e

echo "🔒 Formatting LUKS on $ARCH_PART (all data will be erased)"

# Ensure no mount
umount -R /mnt 2>/dev/null || true

# Close existing mapping if any
cryptsetup close cryptroot 2>/dev/null || true

# Format LUKS and open
cryptsetup luksFormat "$ARCH_PART" --batch-mode
cryptsetup open "$ARCH_PART" cryptroot

# Format Btrfs filesystem
echo "✨ Creating Btrfs filesystem"
mkfs.btrfs -f /dev/mapper/cryptroot

# Mount temporarily
mount /dev/mapper/cryptroot /mnt

# Create subvolumes
echo "✨ Creating Btrfs subvolumes"
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

# Unmount
umount /mnt
