#!/usr/bin/env bash
set -euo pipefail

ui_banner "Bootloader Setup"

# -------------------------------------------------
# Ensure EFI is mounted
# -------------------------------------------------
if ! mountpoint -q /boot; then
    ui_info "Mounting EFI partition $EFI_PART to /boot"
    mount "$EFI_PART" /boot
fi

# -------------------------------------------------
# Install systemd-boot
# -------------------------------------------------
ui_info "Installing systemd-boot..."
bootctl install

# -------------------------------------------------
# Detect root UUID
# -------------------------------------------------
ROOT_UUID=$(blkid -s UUID -o value "${CRYPT_ROOT:-$ROOT_PART}")

# -------------------------------------------------
# Create boot loader entry
# -------------------------------------------------
BOOT_ENTRY="/boot/loader/entries/arch.conf"

ui_info "Creating boot entry: $BOOT_ENTRY"
mkdir -p /boot/loader/entries

cat <<EOF > "$BOOT_ENTRY"
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
EOF

# If encrypted root, add LUKS hook
if [[ -n "${CRYPT_ROOT:-}" ]]; then
    cat <<EOF >> "$BOOT_ENTRY"
options cryptdevice=UUID=$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot rw
EOF
else
    cat <<EOF >> "$BOOT_ENTRY"
options root=UUID=$ROOT_UUID rw
EOF
fi

# -------------------------------------------------
# Set default bootloader
# -------------------------------------------------
ui_info "Setting default bootloader to Arch Linux"
echo "default arch.conf" > /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf

ui_success "Bootloader configured successfully"
