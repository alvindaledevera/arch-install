#!/usr/bin/env bash
set -euo pipefail

ui_banner "Filesystem Setup"

# Determine target device
if [[ "${USE_LUKS:-}" == "yes" ]]; then
    TARGET_DEV="/dev/mapper/cryptroot"
else
    TARGET_DEV="$ROOT_PART"
fi

ui_info "Target device: $TARGET_DEV"

# Unmount previous mounts
umount -R /mnt 2>/dev/null || true
rm -rf /mnt/* 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# Ensure LUKS container is open if encrypted
if [[ "${USE_LUKS:-}" == "yes" ]]; then
    if ! cryptsetup status cryptroot &>/dev/null; then
        ui_info "Opening LUKS container..."
        cryptsetup open "$ROOT_PART" cryptroot
    fi
fi

# Filesystem selection
FS_TYPE="${FS_TYPE:-btrfs}"  # default Btrfs
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

# Format filesystem
if [[ "$FS_TYPE" == "btrfs" ]]; then
    ui_info "Formatting $TARGET_DEV as Btrfs..."
    mkfs.btrfs -f "$TARGET_DEV"

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

export FS_TYPE TARGET_DEV
