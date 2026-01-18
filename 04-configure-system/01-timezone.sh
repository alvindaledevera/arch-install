#!/usr/bin/env bash
set -euo pipefail

ui_banner "Timezone Configuration"

# -------------------------------------------------
# TIMEZONE must exist (from vars.conf or fallback)
# -------------------------------------------------
if [[ -z "${TIMEZONE:-}" ]]; then
    ui_warn "TIMEZONE not set in vars.conf"

    ui_step "Detecting timezone automatically..."
    if curl -fsSL https://ipapi.co/timezone >/dev/null 2>&1; then
        TIMEZONE="$(curl -fsSL https://ipapi.co/timezone)"
        ui_info "Detected timezone: $TIMEZONE"
    else
        TIMEZONE="UTC"
        ui_warn "Timezone detection failed, defaulting to UTC"
    fi
else
    ui_info "Using timezone from vars.conf: $TIMEZONE"
fi

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
# Apply timezone
# -------------------------------------------------
ui_step "Setting timezone to $TIMEZONE"
ln -sf "$ZONEINFO" /etc/localtime

ui_step "Synchronizing hardware clock"
hwclock --systohc

ui_success "Timezone configured successfully"
