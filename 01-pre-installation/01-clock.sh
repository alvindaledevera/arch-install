#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# 01-pre-installation/03-clock.sh
# Pre-installation: System clock and timezone setup
# ------------------------------------------------------------

ui_banner "Pre-installation: System clock"

# -----------------------------
# Enable NTP
# -----------------------------
ui_step "Enabling NTP..."
timedatectl set-ntp true

# -----------------------------
# Timezone logic
# -----------------------------
if [[ -n "${TIMEZONE:-}" ]]; then
    ui_info "Using timezone from vars.conf: $TIMEZONE"
else
    ui_step "Detecting timezone..."
    if curl -fsSL https://ipapi.co/timezone >/dev/null 2>&1; then
        TIMEZONE="$(curl -fsSL https://ipapi.co/timezone)"
        ui_info "Detected timezone: $TIMEZONE"
    else
        ui_warn "Failed to auto-detect timezone"
        ui_step "Falling back to UTC"
        TIMEZONE="UTC"
    fi
fi

# -----------------------------
# Set timezone
# -----------------------------
ui_step "Setting timezone to $TIMEZONE..."
timedatectl set-timezone "$TIMEZONE"

# -----------------------------
# Show current clock status
# -----------------------------
ui_step "Current time status:"
timedatectl status

ui_success "System clock configured"
