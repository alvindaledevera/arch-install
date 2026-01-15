#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# 04-mount.sh
# Mount LUKS + Btrfs subvolumes + EFI
# ==================================================

ui_banner "Mounting Filesystems"

# -------------------------------------------------
# Btrfs mount options
# -------------------------------------------------
BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,commit=120"

# -------------------------------------------------
# Ensure mount points exist
# -------------------------------------------------
mkdir -p "$MOUNT_ROOT" "$MOUNT_BOOT" "$MOUNT_ROOT/home" "$MOUNT_ROOT/.snapshots"

# -------------------------------------------------
# Open LUKS container if needed
# -------------------------------------------------
if [[ -n "${USE_LUKS:-}" ]] && [[ "${USE_LUKS}" =~ ^[Yy]$ ]]; then
    ui_info "Opening LUKS container..."
    cryptsetup open "$ROOT_PART" cryptroot
    TARGET_DEV="/dev/mapper/cryptroot"
else
    TARGET_DEV="$ROOT_PART"
fi

# -------------------------------------------------
# Mount root subvolume
# -------------------------------------------------
ui_info "Mounting root subvolume @ ..."
mount -o "$BTRFS_OPTS,subvol=@" "$TARGET_DEV" "$MOUNT_ROOT"

# -------------------------------------------------
# Mount home subvolume
# -------------------------------------------------
ui_info "Mounting home subvolume @home ..."
mount -o "$BTRFS_OPTS,subvol=@home" "$TARGET_DEV" "$MOUNT_ROOT/home"

# -------------------------------------------------
# Mount snapshots subvolume
# -------------------------------------------------
ui_info "Mounting snapshots subvolume @snapshots ..."
mount -o "$BTRFS_OPTS,subvol=@snapshots" "$TARGET_DEV" "$MOUNT_ROOT/.snapshots"

# -------------------------------------------------
# Mount EFI partition
# -------------------------------------------------
ui_info "Mounting EFI partition ..."
mount "$EFI_PART" "$MOUNT_BOOT"

ui_success "All filesystems mounted successfully"
