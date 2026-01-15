#!/usr/bin/env bash
set -euo pipefail

ui_banner "Disk Encryption (LUKS)"

[[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART is not set"; exit 1; }

# -------------------------------------------------
# Default encryption YES
# -------------------------------------------------
USE_LUKS="${USE_LUKS:-Y}"

if [[ ! "$USE_LUKS" =~ ^[Yy] ]]; then
    ui_info "LUKS encryption skipped"
    export CRYPT_ROOT=""
    return 0 2>/dev/null || exit 0
fi

# -------------------------------------------------
# Unmount and close any existing LUKS container
# -------------------------------------------------
umount -R /mnt 2>/dev/null || true
if cryptsetup status cryptroot &>/dev/null; then
    ui_info "Closing existing LUKS container..."
    cryptsetup close cryptroot
fi

# -------------------------------------------------
# Force reformat if LUKS exists
# -------------------------------------------------
if blkid "$ROOT_PART" | grep -qi crypto_LUKS; then
    ui_warn "Existing LUKS detected, recreating container"
    # Attempt luksErase; ignore errors if not supported
    cryptsetup luksErase "$ROOT_PART" --force 2>/dev/null || true
fi

ui_step "Target partition: $ROOT_PART"
ui_info "You will be prompted for LUKS password"

# -------------------------------------------------
# Format LUKS container
# -------------------------------------------------
cryptsetup luksFormat --type luks2 "$ROOT_PART"

# -------------------------------------------------
# Open LUKS container
# -------------------------------------------------
CRYPT_NAME="cryptroot"
cryptsetup open "$ROOT_PART" "$CRYPT_NAME"
CRYPT_ROOT="/dev/mapper/$CRYPT_NAME"

# -------------------------------------------------
# Verify
# -------------------------------------------------
[[ -b "$CRYPT_ROOT" ]] || { ui_error "Failed to open LUKS device"; exit 1; }
ui_success "LUKS root ready: $CRYPT_ROOT"

# -------------------------------------------------
# Export for next steps
# -------------------------------------------------
export CRYPT_ROOT
