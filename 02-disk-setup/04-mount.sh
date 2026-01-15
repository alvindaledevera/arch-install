#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 04-installation/04-mount.sh
# Mount root, Btrfs subvolumes, and EFI with optimized options
# ===================================================

ui_banner "Mounting Filesystems"

MOUNT_ROOT="${MOUNT_ROOT:-/mnt}"
MOUNT_BOOT="${MOUNT_BOOT:-$MOUNT_ROOT/boot}"

mkdir -p "$MOUNT_ROOT"

# -------------------------------------------------
# Determine target device (LUKS or plain root)
# -------------------------------------------------
TARGET_DEV="${CRYPT_ROOT:-$ROOT_PART}"

[[ -b "$TARGET_DEV" ]] || {
    ui_error "No valid root device found"
    exit 1
}

# -------------------------------------------------
# Unmount any previous mounts
# -------------------------------------------------
umount -R "$MOUNT_ROOT" 2>/dev/null || true

# -------------------------------------------------
# LUKS: open container if necessary
# -------------------------------------------------
if [[ -n "${CRYPT_ROOT:-}" ]]; then
    ui_info "Opening LUKS container..."
    cryptsetup open "$ROOT_PART" cryptroot 2>/dev/null || true
fi

# -------------------------------------------------
# Btrfs mount options (Timeshift-friendly, performance tuned)
# -------------------------------------------------
BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120"

if [[ "$FS_TYPE" == "btrfs" ]]; then
    ui_info "Mounting Btrfs subvolumes"

    # Mount root subvolume
    mount -o "$BTRFS_OPTS,subvol=@" "$TARGET_DEV" "$MOUNT_ROOT"

    # Create mount points
    mkdir -p "$MOUNT_ROOT/home" "$MOUNT_ROOT/.snapshots" "$MOUNT_BOOT"

    # Mount home subvolume
    mount -o "$BTRFS_OPTS,subvol=@home" "$TARGET_DEV" "$MOUNT_ROOT/home"

    # Mount snapshots subvolume (for Timeshift)
    mount -o "$BTRFS_OPTS,subvol=@snapshots" "$TARGET_DEV" "$MOUNT_ROOT/.snapshots"
else
    ui_info "Mounting root filesystem"
    mount "$TARGET_DEV" "$MOUNT_ROOT"

    mkdir -p "$MOUNT_BOOT"
fi

# -------------------------------------------------
# Mount EFI partition if set
# -------------------------------------------------
if [[ -n "${EFI_PART:-}" ]]; then
    ui_info "Mounting EFI partition $EFI_PART → $MOUNT_BOOT"
    mount "$EFI_PART" "$MOUNT_BOOT"
fi

ui_success "Filesystem mounted and ready for installation"

# -------------------------------------------------
# Export for next steps
# -------------------------------------------------
export MOUNT_ROOT MOUNT_BOOT TARGET_DEV
