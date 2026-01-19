#!/usr/bin/env bash
set -euo pipefail


if [[ -z "${TIMEZONE:-}" ]]; then
    ui_warn "TIMEZONE not set in vars.conf"

    ui_step "Detecting timezone automatically..."
    if curl -fsSL https://ipapi.co/timezone >/dev/null 2>&1; then
        TIMEZONE="$(curl -fsSL https://ipapi.co/timezone)"
        ui_info "Detected timezone: $TIMEZONE"
        read -rp "Timezone [Detected: $TIMEZONE]: " TZ_INPUT
        TIMEZONE="${TZ_INPUT:-$TIMEZONE}"
    else
        TIMEZONE="UTC"
        ui_warn "Timezone detection failed, defaulting to UTC"
    fi
else
    ui_info "Using timezone from vars.conf: $TIMEZONE"
fi


if [[ -z "${HOSTNAME:-}" ]]; then
    ui_warn "TIMEZONE not set in vars.conf"
    read -rp "Hostname: " HOSTNAME
else
    ui_info "Using HOSTNAME from vars.conf: $HOSTNAME"
fi


if [[ -z "${KEYMAP:-}" ]]; then
    ui_warn "KEYMAP not set in vars.conf"
    read -rp "KEYMAP layout [us]: " KEYMAP
    KEYMAP="${KEYMAP:-us}"
else
    ui_info "Using KEYMAP from vars.conf: $KEYMAP"
fi


if [[ -z "${LOCALE:-}" ]]; then
    ui_warn "LOCALE not set in vars.conf"
    read -rp "Locale [en_US.UTF-8]: " LOCALE
    LOCALE="${LOCALE:-en_US.UTF-8}"
else
    ui_info "Using LOCALE from vars.conf: $LOCALE"
fi







# -------------------------------------------------
# Pre-installation confirmation (NON-DESTRUCTIVE)
# -------------------------------------------------
ui_banner "Pre-installation: Confirmation"

ui_step "Hostname               : ${HOSTNAME:-<not set>}"
ui_step "Use LUKS Encryption    : ${USE_LUKS:-<not set>}"
ui_step "Locale                 : ${LOCALE:-<not set>}"
ui_step "Keymap                 : ${KEYMAP:-<not set>}"
ui_step "Timezone               : ${TIMEZONE:-<auto>}"
ui_step "User                   : ${USERNAME:-<not set>}"
ui_step "Filesystem             : ${FS_TYPE:-<not set>}"

echo
read -rp "Continue installation? [Y/n]: " ans
ans="${ans:-Y}"

if [[ ! "$ans" =~ ^[Yy]$ ]]; then
    ui_error "Installation aborted by user"
    exit 1
fi


ui_success "Confirmation accepted"
