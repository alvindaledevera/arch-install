#!/usr/bin/env bash
set -euo pipefail

ui_banner "Mounting Filesystems"

# Ensure LUKS is open if encrypted
if [[ "${USE_LUKS:-no}" == "yes" ]]; then
    cryptsetup open "$ROOT_PART" cryptroot 2>/dev/null || true
fi

# Ensure LVM VG is active if LVM enabled
if [[ "${USE_LVM:-no}" == "yes" ]]; then
    vgchange -ay "${VG_NAME:-vg0}" 2>/dev/null || true
fi

# Determine target device if not already set
if [[ -z "${TARGET_DEV:-}" ]]; then
    if [[ "${USE_LVM:-no}" == "yes" ]]; then
        TARGET_DEV="/dev/${VG_NAME:-vg0}/${LV_NAME:-root}"
    elif [[ "${USE_LUKS:-no}" == "yes" ]]; then
        TARGET_DEV="/dev/mapper/cryptroot"
    else
        TARGET_DEV="$ROOT_PART"
    fi
fi

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
