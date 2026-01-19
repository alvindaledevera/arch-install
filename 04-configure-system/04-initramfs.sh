#!/usr/bin/env bash
set -euo pipefail

ui_banner "Initramfs Configuration"

MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# -------------------------------------------------
# Ensure mkinitcpio.conf exists
# -------------------------------------------------
if [[ ! -f "$MKINITCPIO_CONF" ]]; then
    ui_error "mkinitcpio.conf not found at $MKINITCPIO_CONF"
    exit 1
fi

# -------------------------------------------------
# Backup
# -------------------------------------------------
ui_info "Backing up mkinitcpio.conf"
cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"

# -------------------------------------------------
# MODULES
# -------------------------------------------------
MODULES=(atkbd)  # always include keyboard

if [[ "${FS_TYPE:-}" == "btrfs" ]]; then
    MODULES+=(btrfs)
fi

ui_info "Setting MODULES: ${MODULES[*]}"
# Trim spaces and update
sed -i "s/^MODULES=.*/MODULES=(${MODULES[*]})/" "$MKINITCPIO_CONF"

# -------------------------------------------------
# HOOKS (systemd-based)
# -------------------------------------------------
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block)

if [[ "${USE_LUKS:-N}" =~ ^[Yy]$ ]]; then
    ui_info "LUKS enabled → adding sd-encrypt hook"
    # Insert sd-encrypt before filesystems
    HOOKS+=(sd-encrypt)
fi

# Add final hooks
HOOKS+=(filesystems fsck)

ui_info "Setting HOOKS: ${HOOKS[*]}"
sed -i "s/^HOOKS=.*/HOOKS=(${HOOKS[*]})/" "$MKINITCPIO_CONF"

# -------------------------------------------------
# Generate initramfs
# -------------------------------------------------
ui_info "Generating initramfs..."
mkinitcpio -P

ui_success "Initramfs configured successfully ✅"
