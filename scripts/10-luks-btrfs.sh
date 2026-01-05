#!/usr/bin/env bash

# Check if cryptroot already exists
if cryptsetup status cryptroot >/dev/null 2>&1; then
    echo "🔒 cryptroot already mapped."
    read -rp "Do you want to REPLACE existing encryption? This will ERASE data. Type YES to continue: " REPLACE
    if [[ "$REPLACE" == "YES" ]]; then
        # Unmount any mounts first
        umount -R /mnt 2>/dev/null || true
        # Close existing mapping
        cryptsetup close cryptroot
        # Format LUKS again
        cryptsetup luksFormat "$ARCH_PART"
        cryptsetup open "$ARCH_PART" cryptroot
    else
        echo "⚠ Skipping LUKS format, using existing mapping."
    fi
else
    # No existing mapping — safe to luksFormat
    cryptsetup luksFormat "$ARCH_PART"
    cryptsetup open "$ARCH_PART" cryptroot
fi

# Mount and create Btrfs subvolumes only if empty
if ! mount | grep -q /mnt; then
    mount /dev/mapper/cryptroot /mnt
    # Check if subvolumes exist
    if ! btrfs subvolume list /mnt | grep -q "@"; then
        btrfs subvolume create /mnt/@
        btrfs subvolume create /mnt/@home
        btrfs subvolume create /mnt/@snapshots
    fi
    umount /mnt
fi
