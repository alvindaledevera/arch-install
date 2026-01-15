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
# Auto-detect timezone
# -----------------------------
ui_step "Detecting timezone..."
if curl -fsSL https://ipapi.co/timezone >/dev/null 2>&1; then
    TIMEZONE="$(curl -fsSL https://ipapi.co/timezone)"
fi
ui_info "Detected timezone: $TIMEZONE"

# -----------------------------
# Set timezone
# -----------------------------
ui_step "Setting timezone..."
timedatectl set-timezone "$TIMEZONE"

# -----------------------------
# Show current clock status
# -----------------------------
ui_step "Current time status:"
timedatectl status

ui_success "System clock configured"
