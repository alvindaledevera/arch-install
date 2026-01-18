#!/usr/bin/env bash
set -euo pipefail

ui_banner "Filesystem Setup"

# -------------------------------------------------
# Sanity checks
# -------------------------------------------------
[[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART not set"; exit 1; }
[[ -n "${EFI_PART:-}"  ]] || { ui_error "EFI_PART not set";  exit 1; }

# -------------------------------------------------
# Determine target device
# -------------------------------------------------
if [[ "${USE_LUKS:-}" =~ ^[Yy] ]]; then
    TARGET_DEV="/dev/mapper/cryptroot"
else
    TARGET_DEV="$ROOT_PART"
fi

ui_info "Target root device: $TARGET_DEV"
ui_info "EFI partition     : $EFI_PART"

# -------------------------------------------------
# Ensure previous mounts are unmounted
# -------------------------------------------------
ui_info "Unmounting previous mounts..."
umount -R /mnt 2>/dev/null || true
rm -rf /mnt/* 2>/dev/null || true
mkdir -p /mnt /mnt/home /mnt/.snapshots /mnt/boot

# -------------------------------------------------
# Ensure LUKS is open if encryption is enabled
# -------------------------------------------------
if [[ "${USE_LUKS:-}" =~ ^[Yy] ]]; then
    if ! cryptsetup status cryptroot &>/dev/null; then
        ui_info "Opening LUKS container..."
        cryptsetup open "$ROOT_PART" cryptroot
    fi
fi

# -------------------------------------------------
# Ask before formatting EFI (DEFAULT = NO)
# -------------------------------------------------
ui_section "EFI Partition"
read -rp "Format EFI partition ($EFI_PART) as FAT32? [y/N]: " FORMAT_EFI
FORMAT_EFI="${FORMAT_EFI:-N}"

if [[ "$FORMAT_EFI" =~ ^[Yy]$ ]]; then
    ui_warn "Formatting EFI partition as FAT32..."
    umount "$EFI_PART" 2>/dev/null || true
    mkfs.fat -F32 "$EFI_PART"
    ui_success "EFI partition formatted"
else
    ui_info "Skipping EFI format"
fi

# -------------------------------------------------
# Filesystem selection
# -------------------------------------------------
ui_section "Filesystem selection"

if [[ -n "${FS_TYPE:-}" ]]; then
    ui_info "Using filesystem from vars.conf: $FS_TYPE"
else
    FS_TYPE="btrfs"
    echo "  [1] btrfs (default)"
    echo "  [2] ext4"
    read -rp "Choose filesystem (1=btrfs, 2=ext4) [1]: " fs_choice
    case "$fs_choice" in
        2) FS_TYPE="ext4" ;;
        *) FS_TYPE="btrfs" ;;
    esac
fi

ui_info "Selected filesystem: $FS_TYPE"


# -------------------------------------------------
# Format ROOT filesystem
# -------------------------------------------------
if [[ "$FS_TYPE" == "btrfs" ]]; then
    ui_info "Formatting $TARGET_DEV as Btrfs..."
    umount "$TARGET_DEV" 2>/dev/null || true
    mkfs.btrfs -f "$TARGET_DEV"

    ui_info "Mounting root to /mnt..."
    mount "$TARGET_DEV" /mnt

    ui_info "Creating Btrfs subvolumes..."
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots

    ui_info "Unmounting root..."
    umount /mnt
else
    ui_info "Formatting $TARGET_DEV as Ext4..."
    umount "$TARGET_DEV" 2>/dev/null || true
    mkfs.ext4 -F "$TARGET_DEV"
fi

ui_success "Root filesystem formatted successfully"

# -------------------------------------------------
# Export variables for next steps
# -------------------------------------------------
export FS_TYPE TARGET_DEV
