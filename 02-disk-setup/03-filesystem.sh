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
# Unmount previous mounts
# -------------------------------------------------
umount -R /mnt 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# -------------------------------------------------
# Select filesystem
# -------------------------------------------------
FS_TYPE="${FS_TYPE:-btrfs}"  # default Btrfs if not set

ui_section "Filesystem selection"
echo "Available filesystems:"
echo "  [1] btrfs"
echo "  [2] ext4"

if [[ "$FS_TYPE" != "btrfs" && "$FS_TYPE" != "ext4" ]]; then
    read -rp "Choose filesystem (1=btrfs, 2=ext4) [default 1]: " fs_choice
    case "$fs_choice" in
        2) FS_TYPE="ext4" ;;
        *) FS_TYPE="btrfs" ;;
    esac
fi

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
    ui_info "Formatting $TARGET_DEV as Ext4..."
    mkfs.ext4 -F "$TARGET_DEV"
fi

ui_success "Root filesystem formatted"

# -------------------------------------------------
# Export for mount script
# -------------------------------------------------
export FS_TYPE
export TARGET_DEV
