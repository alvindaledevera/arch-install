#!/usr/bin/env bash
set -euo pipefail

ui_banner "Mounting Filesystems"

# -------------------------------------------------
# Determine target device
# -------------------------------------------------
if [[ -n "${USE_LUKS:-}" ]] && [[ "${USE_LUKS}" =~ ^[Yy]$ ]]; then
    TARGET_DEV="/dev/mapper/cryptroot"
else
    TARGET_DEV="$ROOT_PART"
fi

ui_info "Target device: $TARGET_DEV"

# -------------------------------------------------
# Unmount any previous mounts
# -------------------------------------------------
umount -R /mnt 2>/dev/null || true
rm -rf /mnt/* 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# -------------------------------------------------
# Mount filesystem based on type
# -------------------------------------------------
if [[ "${FS_TYPE:-btrfs}" == "btrfs" ]]; then
    ui_info "Mounting Btrfs subvolumes..."

    BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120"

    # Mount root subvolume
    mount -o "${BTRFS_OPTS},subvol=@" "$TARGET_DEV" /mnt

    # Create subvolume mount points
    mkdir -p /mnt/home /mnt/.snapshots

    # Mount home and snapshots
    mount -o "${BTRFS_OPTS},subvol=@home" "$TARGET_DEV" /mnt/home
    mount -o "${BTRFS_OPTS},subvol=@snapshots" "$TARGET_DEV" /mnt/.snapshots
else
    ui_info "Mounting Ext4 root..."
    mount "$TARGET_DEV" /mnt
fi

# -------------------------------------------------
# Mount EFI partition
# -------------------------------------------------
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

ui_success "All filesystems mounted successfully"

# -------------------------------------------------
# Export for next steps
# -------------------------------------------------
export TARGET_DEV
export FS_TYPE
