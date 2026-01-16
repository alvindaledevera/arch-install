#!/usr/bin/env bash
set -euo pipefail

ui_banner "Timezone Configuration"

ui_section "Timezone selection"
ui_info "Default timezone: $TIMEZONE"

read -rp "Enter timezone (e.g. Asia/Manila) [default: $TIMEZONE]: " TIMEZONE
TIMEZONE="${TIMEZONE}"

ZONEINFO="/usr/share/zoneinfo/$TIMEZONE"

# -------------------------------------------------
# Validate timezone
# -------------------------------------------------
if [[ ! -f "$ZONEINFO" ]]; then
    ui_error "Invalid timezone: $TIMEZONE"
    ui_info "Hint: ls /usr/share/zoneinfo/Asia"
    exit 1
fi

# -------------------------------------------------
# Set timezone
# -------------------------------------------------
ui_info "Setting timezone to $TIMEZONE"
ln -sf "$ZONEINFO" /etc/localtime

# -------------------------------------------------
# Sync hardware clock
# -------------------------------------------------
ui_info "Synchronizing hardware clock"
hwclock --systohc

ui_success "Timezone configured successfully"
