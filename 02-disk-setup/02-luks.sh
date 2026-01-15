#!/usr/bin/env bash
set -euo pipefail

ui_banner "Disk Encryption (LUKS)"

[[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART is not set"; exit 1; }

# Force reformat if encrypted (no prompt)
if blkid "$ROOT_PART" | grep -qi crypto_LUKS; then
    ui_warn "Existing LUKS detected, recreating container"
    cryptsetup close cryptroot 2>/dev/null || true
    cryptsetup luksErase "$ROOT_PART" --force 2>/dev/null || true
fi

ui_step "Target partition: $ROOT_PART"
ui_info "You will be prompted for LUKS password"

# Format LUKS container
cryptsetup luksFormat --type luks2 "$ROOT_PART"

# Open LUKS container
CRYPT_NAME="cryptroot"
cryptsetup open "$ROOT_PART" "$CRYPT_NAME"
CRYPT_ROOT="/dev/mapper/$CRYPT_NAME"

# Verify
[[ -b "$CRYPT_ROOT" ]] || { ui_error "Failed to open LUKS device"; exit 1; }
ui_success "LUKS root ready: $CRYPT_ROOT"

# Export
export CRYPT_ROOT
