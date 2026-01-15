#!/usr/bin/env bash
set -euo pipefail

ui_banner "Filesystem Setup"

# Determine target device
if [[ "${USE_LUKS:-}" == "yes" ]]; then
    TARGET_DEV="/dev/mapper/cryptroot"
    RAW_DEV="$ROOT_PART"
else
    TARGET_DEV="$ROOT_PART"
    RAW_DEV="$ROOT_PART"
fi

ui_info "Target device: $TARGET_DEV"

# Unmount / clean previous mounts
umount -R /mnt 2>/dev/null || true
rm -rf /mnt/* 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# Close LUKS temporarily if formatting Ext4
if [[ "${USE_LUKS:-}" == "yes" ]] && cryptsetup status cryptroot &>/dev/null; then
    ui_info "Closing LUKS container temporarily for formatting..."
    cryptsetup close cryptroot
fi

# Filesystem selection (default Btrfs)
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

# Format filesystem
if [[ "$FS_TYPE" == "btrfs" ]]; then
    [[ "${USE_LUKS:-}" == "yes" ]] && cryptsetup open "$RAW_DEV" cryptroot
    ui_info "Formatting $TARGET_DEV as Btrfs..."
    mkfs.btrfs -f "$TARGET_DEV"

    mount "$TARGET_DEV" /mnt
    ui_info "Creating Btrfs subvolumes: @, @home, @snapshots..."
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    umount /mnt
else
    ui_info "Formatting $RAW_DEV as Ext4..."
    mkfs.ext4 -F "$RAW_DEV"
    [[ "${USE_LUKS:-}" == "yes" ]] && cryptsetup open "$RAW_DEV" cryptroot && TARGET_DEV="/dev/mapper/cryptroot"
fi

ui_success "Root filesystem formatted"

# Export for mount script
export FS_TYPE TARGET_DEV
