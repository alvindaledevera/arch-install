#!/usr/bin/env bash
set -euo pipefail

ui_banner "Filesystem Setup"

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
# Unmount previous mounts & prepare directories
# -------------------------------------------------
umount -R /mnt 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# -------------------------------------------------
# Select filesystem (default Btrfs)
# -------------------------------------------------
FS_TYPE="${FS_TYPE:-btrfs}"

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
    # EXT4 formatting
    ui_info "Formatting $TARGET_DEV as Ext4..."
    mkfs.ext4 -F "$TARGET_DEV"
fi

ui_success "Root filesystem formatted"

# -------------------------------------------------
# Export for mount script
# -------------------------------------------------
export FS_TYPE
export TARGET_DEV
