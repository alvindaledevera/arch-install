#!/usr/bin/env bash
set -euo pipefail

ui_banner "Bootloader Setup (systemd-boot)"

# -------------------------------------------------
# Only proceed if in UEFI
# -------------------------------------------------
if [[ ! -d /sys/firmware/efi ]]; then
    ui_warn "System not booted in UEFI mode, skipping EFI variable changes."
fi

# -------------------------------------------------
# Check required variables
# -------------------------------------------------
[[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART not set"; exit 1; }
FS_TYPE="${FS_TYPE,,}"     # lowercase
USE_LUKS="${USE_LUKS,,}"   # lowercase

# -------------------------------------------------
# Install systemd-boot
# -------------------------------------------------
ui_info "Installing systemd-boot..."
bootctl install || ui_warn "bootctl install skipped (probably chroot)"

# -------------------------------------------------
# Kernel and initramfs images
# -------------------------------------------------
KERNEL_IMAGE="/vmlinuz-linux"
INITRAMFS_IMAGE="/initramfs-linux.img"

# -------------------------------------------------
# Root flags
# -------------------------------------------------
ROOT_FLAGS="rw"
[[ "$FS_TYPE" == "btrfs" ]] && ROOT_FLAGS+=" rootflags=subvol=@ loglevel=3"

# -------------------------------------------------
# Kernel boot options
# -------------------------------------------------
OPTIONS=""

if [[ "$USE_LUKS" == "y" || "$USE_LUKS" == "yes" ]]; then
    # LUKS enabled
    LUKS_UUID="$(blkid -s UUID -o value "$ROOT_PART")"
    OPTIONS+="rd.luks.name=${LUKS_UUID}=cryptroot root=/dev/mapper/cryptroot "
else
    # No encryption
    ROOT_UUID="$(blkid -s UUID -o value "$ROOT_PART")"
    OPTIONS+="root=UUID=${ROOT_UUID} "
fi

OPTIONS+="$ROOT_FLAGS"
OPTIONS="$(echo "$OPTIONS" | xargs)"  # trim extra spaces

# -------------------------------------------------
# Write boot entry
# -------------------------------------------------
ENTRY_FILE="/boot/loader/entries/arch.conf"
ui_info "Creating boot entry: $ENTRY_FILE"
cat <<EOF > "$ENTRY_FILE"
title   Arch Linux
linux   $KERNEL_IMAGE
initrd  $INITRAMFS_IMAGE
options $OPTIONS
EOF

# -------------------------------------------------
# Configure loader.conf
# -------------------------------------------------
ui_info "Configuring loader.conf"
cat <<EOF > /boot/loader/loader.conf
default arch
timeout 5
editor no
EOF

ui_success "Bootloader configured successfully ✅"
