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
# Determine mkinitcpio hooks
# -------------------------------------------------
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

ui_info "Backing up mkinitcpio.conf..."
cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"

# -----------------------------
# Default hooks
# -----------------------------
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)

# -----------------------------
# Add 'encrypt' hook if LUKS is enabled
# -----------------------------
if [[ "${USE_LUKS:-N}" =~ ^[Yy] ]]; then
    ui_info "LUKS detected: adding 'encrypt' hook"
    # Insert 'encrypt' after 'block'
    # Find index of 'block'
    for i in "${!HOOKS[@]}"; do
        if [[ "${HOOKS[$i]}" == "block" ]]; then
            INSERT_INDEX=$((i+1))
            break
        fi
    done
    # Insert encrypt
    HOOKS=("${HOOKS[@]:0:$INSERT_INDEX}" encrypt "${HOOKS[@]:$INSERT_INDEX}")
fi

# -----------------------------
# Add 'btrfs' hook if root filesystem is Btrfs
# -----------------------------
if [[ "${FS_TYPE:-btrfs}" == "btrfs" ]]; then
    ui_info "Btrfs root detected: adding 'btrfs' hook"
    HOOKS+=(btrfs)
fi

# -----------------------------
# Update mkinitcpio.conf
# -----------------------------
HOOKS_STRING="${HOOKS[*]}"
ui_info "Updating HOOKS in $MKINITCPIO_CONF"
sed -i "s|^HOOKS=.*|HOOKS=(${HOOKS_STRING})|" "$MKINITCPIO_CONF"

# -----------------------------
# Regenerate initramfs
# -----------------------------
ui_info "Regenerating initramfs for kernel $KERNEL_PKG..."
mkinitcpio -P

ui_success "Initramfs regenerated successfully"
