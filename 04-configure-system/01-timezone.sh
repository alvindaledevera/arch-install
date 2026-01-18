#!/usr/bin/env bash
set -euo pipefail

ui_banner "Timezone Configuration"

# -------------------------------------------------
# Auto-detect timezone if not set
# -------------------------------------------------
if [[ -n "${TIMEZONE:-}" ]]; then
    ui_info "Using timezone from vars.conf: $TIMEZONE"
else
    if [[ -z "${TIMEZONE:-}" ]]; then
        ui_step "Detecting timezone..."
        if curl -fsSL https://ipapi.co/timezone >/dev/null 2>&1; then
            TIMEZONE="$(curl -fsSL https://ipapi.co/timezone)"
            ui_info "Detected timezone: $TIMEZONE"
        else
            TIMEZONE="UTC"
            ui_warn "Could not detect timezone automatically. Defaulting to UTC."
        fi
    fi

    # -------------------------------------------------
    # Ask user to confirm or override
    # -------------------------------------------------
    ui_section "Timezone selection"
    read -rp "Enter timezone (e.g., Asia/Manila) [default: $TIMEZONE]: " INPUT_TZ
    if [[ -n "$INPUT_TZ" ]]; then
        TIMEZONE="$INPUT_TZ"
    fi
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
