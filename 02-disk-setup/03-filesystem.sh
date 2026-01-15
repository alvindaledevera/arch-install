#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 03-installation/03-filesystem.sh
# Format root partition and create Btrfs subvolumes
# ===================================================

ui_banner "Filesystem Setup"

# -------------------------------------------------
# Determine target device
# -------------------------------------------------
TARGET_DEV="${CRYPT_ROOT:-$ROOT_PART}"

[[ -b "$TARGET_DEV" ]] || {
    ui_error "No valid root device found"
    exit 1
}

ui_info "Target device: $TARGET_DEV"

# -------------------------------------------------
# Format ROOT partition
# -------------------------------------------------
case "$FS_TYPE" in
    btrfs)
        ui_info "Formatting root as BTRFS..."
        mkfs.btrfs -f "$TARGET_DEV"
        ;;
    ext4)
        ui_info "Formatting root as EXT4..."
        mkfs.ext4 -F "$TARGET_DEV"
        ;;
    *)
        ui_error "Unsupported filesystem: $FS_TYPE"
        exit 1
        ;;
esac

ui_success "Root filesystem formatted"
