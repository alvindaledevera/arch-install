#!/usr/bin/env bash
set -euo pipefail

ui_banner "Initramfs Configuration"

# -------------------------------------------------
# Default kernel
# -------------------------------------------------
KERNEL_PKG="${KERNEL_PKG:-linux}"

ui_info "Checking installed kernel: $KERNEL_PKG"
if ! pacman -Qi "$KERNEL_PKG" &>/dev/null; then
    ui_error "Kernel package $KERNEL_PKG not installed"
    exit 1
fi

# -------------------------------------------------
# Configure mkinitcpio
# -------------------------------------------------
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

ui_info "Backing up mkinitcpio.conf..."
cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"

ui_info "Updating HOOKS for LUKS/BTRFS setup..."
# Minimal recommended for encrypted Btrfs root
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)/' "$MKINITCPIO_CONF"

# -------------------------------------------------
# Regenerate initramfs
# -------------------------------------------------
ui_info "Regenerating initramfs..."
mkinitcpio -P

ui_success "Initramfs regenerated successfully"
