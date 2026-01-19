#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------
# Load UI
# ----------------------------------
if [[ -f /root/arch-install/lib/ui.sh ]]; then
    source /root/arch-install/lib/ui.sh
else
    echo "[WARN] ui.sh not found, continuing without UI functions"
    ui_banner() { echo "=== $* ==="; }
    ui_info() { echo "[INFO] $*"; }
    ui_success() { echo "[OK] $*"; }
    ui_warn() { echo "[WARN] $*"; }
fi

ui_banner "Initramfs Configuration"

# ----------------------------------
# Load installer variables
# ----------------------------------
if [[ -f /root/arch-install/vars.conf ]]; then
    source /root/arch-install/vars.conf
else
    ui_warn "vars.conf not found in chroot, using defaults"
fi

# ----------------------------------
# Ensure /boot is mounted
# ----------------------------------
if ! mountpoint -q /boot; then
    ui_warn "/boot is not mounted. Attempting to mount..."
    mount /boot || ui_warn "Failed to mount /boot, mkinitcpio may fail"
fi

MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# ----------------------------------
# Backup mkinitcpio.conf
# ----------------------------------
ui_info "Backing up $MKINITCPIO_CONF"
cp -f "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"

# ----------------------------------
# Configure MODULES
# ----------------------------------
MODULES=()

# Filesystem modules
if [[ "${FS_TYPE:-}" == "btrfs" ]]; then
    MODULES+=(btrfs)
elif [[ "${FS_TYPE:-}" == "ext4" ]]; then
    MODULES+=(ext4)
fi

# Keyboard module
MODULES+=(atkbd)

ui_info "Setting MODULES: ${MODULES[*]}"
sed -i "s/^MODULES=.*/MODULES=(${MODULES[*]})/" "$MKINITCPIO_CONF"

# ----------------------------------
# Configure HOOKS (systemd-based)
# ----------------------------------
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block)

if [[ "${USE_LUKS:-N}" =~ ^[Yy]$ ]]; then
    ui_info "LUKS enabled → adding sd-encrypt hook"
    HOOKS+=(sd-encrypt)
fi

HOOKS+=(filesystems fsck)

ui_info "Setting HOOKS: ${HOOKS[*]}"
sed -i "s/^HOOKS=.*/HOOKS=(${HOOKS[*]})/" "$MKINITCPIO_CONF"

# ----------------------------------
# Generate initramfs
# ----------------------------------
ui_info "Generating initramfs images..."
mkinitcpio -P || ui_warn "mkinitcpio encountered warnings/errors, check output"

ui_success "Initramfs configured successfully ✅"
