#!/usr/bin/env bash
set -euo pipefail

ui_banner "Generating fstab"

# -------------------------------------------------
# Sanity checks
# -------------------------------------------------
mountpoint -q /mnt || {
    ui_error "/mnt is not mounted"
    exit 1
}

# -------------------------------------------------
# Generate fstab
# -------------------------------------------------
ui_info "Generating fstab..."
genfstab -U /mnt > /mnt/etc/fstab

ui_success "fstab generated"

ui_info "fstab contents:"
echo "--------------------------------------------------"
cat /mnt/etc/fstab
echo "--------------------------------------------------"
