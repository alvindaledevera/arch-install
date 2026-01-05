#!/usr/bin/env bash
set -e

# -----------------------------
# 10-luks-btrfs.sh
# -----------------------------

# 1️⃣ Close existing mapping if needed
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
        # Ensure it's open
        cryptsetup open "$ARCH_PART" cryptroot 2>/dev/null || true
    fi
else
    # No existing mapping — safe to luksFormat
    cryptsetup luksFormat "$ARCH_PART"
    cryptsetup open "$ARCH_PART" cryptroot
fi

# 2️⃣ Make sure Btrfs filesystem exists
if ! blkid /dev/mapper/cryptroot | grep -q 'TYPE="btrfs"'; then
    echo "✨ Creating Btrfs filesystem on /dev/mapper/cryptroot"
    mkfs.btrfs -f /dev/mapper/cryptroot
fi

# 3️⃣ Mount and create subvolumes if not exist
if ! mount | grep -q /mnt; then
    mount /dev/mapper/cryptroot /mnt

    # Create subvolumes only if they don't exist
    if ! btrfs subvolume list /mnt | grep -q "@"; then
        echo "✨ Creating Btrfs subvolumes"
        btrfs subvolume create /mnt/@
        btrfs subvolume create /mnt/@home
        btrfs subvolume create /mnt/@snapshots
    else
        echo "⚠ Btrfs subvolumes already exist, skipping"
    fi

    umount /mnt
fi
