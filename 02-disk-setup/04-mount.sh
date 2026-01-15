#!/usr/bin/env bash
set -euo pipefail

ui_banner "Mounting Filesystems"

# -------------------------------------------------
# Determine device
# -------------------------------------------------
if [[ "$FS_TYPE" == "btrfs" ]]; then
    BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120"

    ui_info "Mounting root subvolume @ ..."
    mount -o "$BTRFS_OPTS,subvol=@" "$TARGET_DEV" /mnt

    ui_info "Mounting home subvolume @home ..."
    mount -o "$BTRFS_OPTS,subvol=@home" "$TARGET_DEV" /mnt/home

    ui_info "Mounting snapshots subvolume @snapshots ..."
    mount -o "$BTRFS_OPTS,subvol=@snapshots" "$TARGET_DEV" /mnt/.snapshots
else
    ui_info "Mounting Ext4 root ..."
    mount "$TARGET_DEV" /mnt
    mkdir -p /mnt/home /mnt/.snapshots
fi

# -------------------------------------------------
# Mount EFI
# -------------------------------------------------
ui_info "Mounting EFI partition $EFI_PART ..."
mount "$EFI_PART" /mnt/boot

ui_success "All filesystems mounted successfully"

# -------------------------------------------------
# Export mounts
# -------------------------------------------------
export MOUNT_ROOT="/mnt"
export MOUNT_BOOT="/mnt/boot"
export CRYPT_ROOT="$TARGET_DEV"
