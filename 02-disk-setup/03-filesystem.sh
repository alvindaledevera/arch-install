#!/usr/bin/env bash
set -euo pipefail

ui_banner "Filesystem Setup"

# -------------------------------------------------
# Default filesystem type
# -------------------------------------------------
FS_TYPE="${FS_TYPE:-btrfs}"  # default Btrfs if not set

# -------------------------------------------------
# Determine target device
# -------------------------------------------------
if [[ -n "${USE_LUKS:-}" ]] && [[ "${USE_LUKS}" =~ ^[Yy] ]]; then
    RAW_DEV="$ROOT_PART"
    TARGET_DEV="/dev/mapper/cryptroot"
else
    RAW_DEV="$ROOT_PART"
    TARGET_DEV="$ROOT_PART"
fi

ui_info "Target device: $TARGET_DEV"

# -------------------------------------------------
# Ensure /mnt is clean
# -------------------------------------------------
umount -R /mnt 2>/dev/null || true
rm -rf /mnt/* 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# -------------------------------------------------
# Select filesystem
# -------------------------------------------------
ui_section "Filesystem selection"
echo "Available filesystems:"
echo "  [1] btrfs"
echo "  [2] ext4"

read -rp "Choose filesystem (1=btrfs, 2=ext4) [default 1]: " fs_choice
case "$fs_choice" in
    2) FS_TYPE="ext4" ;;
    *) FS_TYPE="btrfs" ;;
esac

ui_info "Selected filesystem: $FS_TYPE"

# -------------------------------------------------
# Format filesystem
# -------------------------------------------------
if [[ "$FS_TYPE" == "btrfs" ]]; then
    # Open LUKS if needed
    if [[ -n "${USE_LUKS:-}" ]] && [[ "$USE_LUKS" =~ ^[Yy] ]]; then
        cryptsetup open "$RAW_DEV" cryptroot
    fi

    ui_info "Formatting $TARGET_DEV as Btrfs..."
    mkfs.btrfs -f "$TARGET_DEV"

    # Temporary mount for subvolume creation
    mount "$TARGET_DEV" /mnt
    ui_info "Creating Btrfs subvolumes: @, @home, @snapshots..."
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    umount /mnt

else
    # Format Ext4 on RAW or LUKS
    if [[ -n "${USE_LUKS:-}" ]] && [[ "$USE_LUKS" =~ ^[Yy] ]]; then
        # Close LUKS if open
        if cryptsetup status cryptroot &>/dev/null; then
            ui_info "Closing LUKS container temporarily for Ext4 formatting..."
            cryptsetup close cryptroot
        fi
        TARGET_DEV="$RAW_DEV"
    fi

    ui_info "Formatting $TARGET_DEV as Ext4..."
    mkfs.ext4 -F "$TARGET_DEV"

    # Reopen LUKS if needed
    if [[ -n "${USE_LUKS:-}" ]] && [[ "$USE_LUKS" =~ ^[Yy] ]]; then
        cryptsetup open "$RAW_DEV" cryptroot
        TARGET_DEV="/dev/mapper/cryptroot"
    fi
fi

ui_success "Root filesystem formatted"

# -------------------------------------------------
# Export variables for mount step
# -------------------------------------------------
export FS_TYPE
export TARGET_DEV
