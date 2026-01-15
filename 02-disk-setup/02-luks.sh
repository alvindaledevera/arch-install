#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 02-disk-setup/02-luks.sh
# Optional LUKS encryption for root partition
# ===================================================

ui_banner "Disk Encryption (LUKS)"

# -------------------------------------------------
# Skip if user chose no encryption
# -------------------------------------------------
if [[ "${USE_LUKS:-N}" =~ ^[Nn]$ ]]; then
    ui_info "LUKS encryption skipped"
    export CRYPT_ROOT=""
    return 0 2>/dev/null || exit 0
fi

# -------------------------------------------------
# Safety checks
# -------------------------------------------------
[[ -n "${ROOT_PART:-}" ]] || {
    ui_error "ROOT_PART is not set"
    exit 1
}

# -------------------------------------------------
# Handle existing LUKS / mounted partition
# -------------------------------------------------
if blkid "$ROOT_PART" | grep -qi crypto_LUKS; then
    ui_warn "Existing LUKS detected on $ROOT_PART"
    ui_warn "Recreating encrypted container (NO confirmation)"

    # Close if open
    if cryptsetup status cryptroot &>/dev/null; then
        ui_warn "Closing existing LUKS container..."
        cryptsetup close cryptroot || true
    fi

    # Unmount if mounted
    if mount | grep -q "$ROOT_PART"; then
        ui_warn "Unmounting $ROOT_PART..."
        umount -R "$ROOT_PART" || true
    fi

    # Wipe LUKS header to prevent conflicts
    ui_info "Wiping existing LUKS header..."
    cryptsetup luksErase "$ROOT_PART" 2>/dev/null || true
else
    ui_warn "Encrypting ROOT partition (WILL ERASE DATA)"
fi

# -------------------------------------------------
# Proceed with encryption
# -------------------------------------------------
ui_step "Target partition: $ROOT_PART"
ui_info "You will be prompted for LUKS password"

# Force reformat (-q = quiet, --type luks2 explicit)
cryptsetup luksFormat --type luks2 "$ROOT_PART"

# -------------------------------------------------
# Open LUKS container
# -------------------------------------------------
CRYPT_NAME="cryptroot"

ui_info "Opening LUKS container..."
cryptsetup open "$ROOT_PART" "$CRYPT_NAME"

CRYPT_ROOT="/dev/mapper/$CRYPT_NAME"

# -------------------------------------------------
# Verify
# -------------------------------------------------
[[ -b "$CRYPT_ROOT" ]] || {
    ui_error "Failed to open LUKS device"
    exit 1
}

ui_success "LUKS root ready: $CRYPT_ROOT"

# -------------------------------------------------
# Export for filesystem step
# -------------------------------------------------
export CRYPT_ROOT
