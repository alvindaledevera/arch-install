#!/usr/bin/env bash
set -euo pipefail

ui_banner "Disk Encryption (LUKS)"

[[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART is not set"; exit 1; }

# -------------------------------------------------
# Determine USE_LUKS (from vars.conf or ask user)
# -------------------------------------------------
if [[ -z "${USE_LUKS:-}" ]]; then
    read -rp "Encrypt root partition with LUKS? [Y/n]: " USE_LUKS
    USE_LUKS="${USE_LUKS:-Y}"
fi

USE_LUKS="${USE_LUKS,,}"   # normalize to lowercase

# Validate input
case "$USE_LUKS" in
    y|yes)
        USE_LUKS="yes"
        ;;
    n|no)
        USE_LUKS="no"
        ;;
    *)
        ui_error "Invalid answer: $USE_LUKS (use y/n/yes/no)"
        exit 1
        ;;
esac

export USE_LUKS

# -------------------------------------------------
# If encryption is skipped
# -------------------------------------------------
if [[ "$USE_LUKS" == "no" ]]; then
    ui_info "LUKS encryption skipped"

    ui_info "Unmounting any mounts using cryptroot..."
    umount -R /mnt 2>/dev/null || true

    if cryptsetup status cryptroot &>/dev/null; then
        ui_warn "Closing existing LUKS container..."
        cryptsetup close cryptroot || {
            ui_error "Failed to close cryptroot (device still in use)"
            exit 1
        }
    fi

    unset CRYPT_ROOT
    export CRYPT_ROOT=""

    return 0 2>/dev/null || exit 0
fi


# -------------------------------------------------
# Ensure nothing is mounted / opened
# -------------------------------------------------
ui_info "Unmounting any previous mounts..."
umount -R /mnt 2>/dev/null || true

if cryptsetup status cryptroot &>/dev/null; then
    ui_info "Closing existing LUKS container..."
    cryptsetup close cryptroot
fi

# -------------------------------------------------
# Wipe existing LUKS header if present
# -------------------------------------------------
if blkid "$ROOT_PART" | grep -qi crypto_LUKS; then
    ui_warn "Existing LUKS detected, recreating container"
    cryptsetup luksErase "$ROOT_PART"
fi


ui_step "Target partition: $ROOT_PART"
ui_info "You will be prompted for LUKS passphrase"

# -------------------------------------------------
# LUKS format (retry on failure)
# -------------------------------------------------
set +e
while true; do
    cryptsetup luksFormat --type luks2 "$ROOT_PART"
    STATUS=$?

    if [[ $STATUS -eq 0 ]]; then
        break
    fi

    ui_warn "Passphrases did not match or operation failed."
    read -rp "Try again? [Y/n]: " RETRY
    RETRY="${RETRY:-Y}"
    RETRY="${RETRY,,}"   # normalize

    if [[ ! "$RETRY" =~ ^(y|yes)$ ]]; then
        ui_error "LUKS setup aborted by user"
        exit 1
    fi
done
set -e

# -------------------------------------------------
# Open LUKS container
# -------------------------------------------------
CRYPT_NAME="cryptroot"
cryptsetup open "$ROOT_PART" "$CRYPT_NAME"

CRYPT_ROOT="/dev/mapper/$CRYPT_NAME"
export CRYPT_ROOT

# -------------------------------------------------
# Verify
# -------------------------------------------------
if [[ ! -b "$CRYPT_ROOT" ]]; then
    ui_error "Failed to open LUKS device"
    exit 1
fi

ui_success "LUKS root ready: $CRYPT_ROOT"
