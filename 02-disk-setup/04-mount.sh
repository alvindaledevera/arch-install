#!/usr/bin/env bash
set -euo pipefail

ui_banner "Mounting Filesystems"

# Open LUKS if encrypted
[[ "${USE_LUKS:-}" == "yes" ]] && cryptsetup open "$ROOT_PART" cryptroot 2>/dev/null || true

BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120"

if [[ "$FS_TYPE" == "btrfs" ]]; then
    mount -o $BTRFS_OPTS,subvol=@ "$TARGET_DEV" /mnt
    mkdir -p /mnt/home /mnt/.snapshots /mnt/boot
    mount -o $BTRFS_OPTS,subvol=@home "$TARGET_DEV" /mnt/home
    mount -o $BTRFS_OPTS,subvol=@snapshots "$TARGET_DEV" /mnt/.snapshots
else
    mount "$TARGET_DEV" /mnt
    mkdir -p /mnt/home /mnt/.snapshots /mnt/boot
fi

# Mount EFI
mount "$EFI_PART" /mnt/boot

ui_success "All filesystems mounted"
