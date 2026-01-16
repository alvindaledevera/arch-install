#!/usr/bin/env bash
set -euo pipefail

ui_banner "Bootloader Setup (systemd-boot)"

# -------------------------------------------------
# Sanity checks
# -------------------------------------------------
[[ -d /sys/firmware/efi ]] || {
    ui_error "System not booted in UEFI mode"
    exit 1
}

[[ -n "${ROOT_PART:-}" ]] || {
    ui_error "ROOT_PART not set"
    exit 1
}

# -------------------------------------------------
# Install systemd-boot
# -------------------------------------------------
ui_info "Installing systemd-boot..."
bootctl install

# -------------------------------------------------
# Kernel paths
# -------------------------------------------------
KERNEL_IMAGE="/vmlinuz-linux"
INITRAMFS_IMAGE="/initramfs-linux.img"

# -------------------------------------------------
# Root flags
# -------------------------------------------------
ROOT_FLAGS="rw"

if [[ "${FS_TYPE:-}" == "btrfs" ]]; then
    ROOT_FLAGS+=" rootflags=subvol=@"
fi

# -------------------------------------------------
# Kernel options
# -------------------------------------------------
OPTIONS=""

if [[ "${USE_LUKS:-N}" =~ ^[Yy]$ ]]; then
    ui_info "Configuring encrypted root"

    LUKS_UUID="$(blkid -s UUID -o value "$ROOT_PART")"

    OPTIONS+="rd.luks.name=${LUKS_UUID}=cryptroot "
    OPTIONS+="root=/dev/mapper/cryptroot "
else
    ui_info "Configuring unencrypted root"

    ROOT_UUID="$(blkid -s UUID -o value "$ROOT_PART")"
    OPTIONS+="root=UUID=${ROOT_UUID} "
fi

OPTIONS+="$ROOT_FLAGS"

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
# loader.conf
# -------------------------------------------------
ui_info "Configuring loader.conf"

cat <<EOF > /boot/loader/loader.conf
default arch
timeout 5
editor no
EOF

ui_success "Bootloader configured successfully"
