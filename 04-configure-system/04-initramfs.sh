#!/usr/bin/env bash
set -euo pipefail

ui_banner "Initramfs Configuration"

MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# -------------------------------------------------
# Backup
# -------------------------------------------------
ui_info "Backing up mkinitcpio.conf"
cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"

# -------------------------------------------------
# MODULES
# -------------------------------------------------
MODULES=()

# Add btrfs module if needed
if [[ "${FS_TYPE:-}" == "btrfs" ]]; then
    MODULES+=(btrfs)
fi

# Keyboard module (safe)
MODULES+=(atkbd)

ui_info "Setting MODULES: ${MODULES[*]}"
sed -i "s/^MODULES=.*/MODULES=(${MODULES[*]})/" "$MKINITCPIO_CONF"

# -------------------------------------------------
# HOOKS (systemd-based)
# -------------------------------------------------
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block)

if [[ "${USE_LUKS:-N}" =~ ^[Yy]$ ]]; then
    ui_info "LUKS enabled → adding sd-encrypt hook"
    HOOKS+=(sd-encrypt)
fi

HOOKS+=(filesystems fsck)

ui_info "Setting HOOKS: ${HOOKS[*]}"
sed -i "s/^HOOKS=.*/HOOKS=(${HOOKS[*]})/" "$MKINITCPIO_CONF"

# -------------------------------------------------
# Generate initramfs
# -------------------------------------------------
ui_info "Generating initramfs..."
mkinitcpio -P

ui_success "Initramfs configured successfully"
