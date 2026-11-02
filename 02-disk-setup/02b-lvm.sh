#!/usr/bin/env bash
set -euo pipefail

ui_banner "LVM Setup"

# -------------------------------------------------
# Determine USE_LVM (from vars.conf or ask user)
# -------------------------------------------------
if [[ -z "${USE_LVM:-}" ]]; then
    read -rp "Use LVM (Logical Volume Manager)? [Y/n]: " USE_LVM
    USE_LVM="${USE_LVM:-Y}"
fi

USE_LVM="${USE_LVM,,}" # normalize to lowercase

case "$USE_LVM" in
    y|yes)
        USE_LVM="yes"
        ;;
    n|no)
        USE_LVM="no"
        ;;
    *)
        ui_error "Invalid answer: $USE_LVM (use y/n/yes/no)"
        exit 1
        ;;
esac

export USE_LVM

# -------------------------------------------------
# If LVM is skipped
# -------------------------------------------------
if [[ "$USE_LVM" == "no" ]]; then
    ui_info "LVM setup skipped"

    if [[ "${USE_LUKS:-no}" == "yes" ]]; then
        TARGET_DEV="/dev/mapper/cryptroot"
    else
        [[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART is not set"; exit 1; }
        TARGET_DEV="$ROOT_PART"
    fi

    export TARGET_DEV
    return 0 2>/dev/null || exit 0
fi

# -------------------------------------------------
# Determine PV device (LUKS mapper or raw partition)
# -------------------------------------------------
if [[ "${USE_LUKS:-no}" == "yes" ]]; then
    PV_DEV="/dev/mapper/cryptroot"
    if [[ ! -b "$PV_DEV" ]]; then
        ui_error "LUKS device $PV_DEV not found. Ensure LUKS setup succeeded."
        exit 1
    fi
else
    [[ -n "${ROOT_PART:-}" ]] || { ui_error "ROOT_PART is not set"; exit 1; }
    PV_DEV="$ROOT_PART"
fi

VG_NAME="${VG_NAME:-vg0}"
LV_NAME="${LV_NAME:-root}"

ui_step "Physical Volume (PV) device: $PV_DEV"
ui_step "Volume Group (VG) name    : $VG_NAME"
ui_step "Logical Volume (LV) name  : $LV_NAME"

# -------------------------------------------------
# Clean up existing Volume Group / Physical Volume if present
# -------------------------------------------------
ui_info "Deactivating any existing Volume Groups..."
vgchange -an "$VG_NAME" 2>/dev/null || true

if vgdisplay "$VG_NAME" &>/dev/null; then
    ui_warn "Existing Volume Group '$VG_NAME' detected, removing..."
    vgremove -f "$VG_NAME"
fi

if pvdisplay "$PV_DEV" &>/dev/null; then
    ui_warn "Existing Physical Volume on '$PV_DEV' detected, removing..."
    pvremove -f "$PV_DEV"
fi

# -------------------------------------------------
# Create LVM structures
# -------------------------------------------------
ui_info "Creating Physical Volume on $PV_DEV..."
pvcreate -f "$PV_DEV"

ui_info "Creating Volume Group '$VG_NAME' on $PV_DEV..."
vgcreate -f "$VG_NAME" "$PV_DEV"

ui_info "Creating Logical Volume '$LV_NAME' using 100% free space..."
lvcreate -l 100%FREE -n "$LV_NAME" "$VG_NAME"

TARGET_DEV="/dev/$VG_NAME/$LV_NAME"

# -------------------------------------------------
# Verify
# -------------------------------------------------
if [[ ! -b "$TARGET_DEV" ]]; then
    ui_error "Failed to create logical volume device $TARGET_DEV"
    exit 1
fi

export VG_NAME LV_NAME TARGET_DEV
ui_success "LVM setup complete: $TARGET_DEV"
