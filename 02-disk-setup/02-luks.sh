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

if blkid "$ROOT_PART" | grep -qi crypto_LUKS; then
    ui_warn "Partition already encrypted: $ROOT_PART"
else
    ui_warn "ROOT partition WILL BE ERASED"
    ui_step "Partition: $ROOT_PART"

    read -rp "Type ENCRYPT to continue: " CONFIRM
    [[ "$CONFIRM" == "ENCRYPT" ]] || {
        ui_error "Encryption aborted"
        exit 1
    }

    ui_info "Encrypting $ROOT_PART with LUKS2..."
    cryptsetup luksFormat "$ROOT_PART"
fi

# -------------------------------------------------
# Open LUKS container
# -------------------------------------------------
CRYPT_NAME="cryptroot"

if cryptsetup status "$CRYPT_NAME" &>/dev/null; then
    ui_info "LUKS container already opened"
else
    ui_info "Opening LUKS container..."
    cryptsetup open "$ROOT_PART" "$CRYPT_NAME"
fi

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
