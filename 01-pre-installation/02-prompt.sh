#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# Defaults (safe kahit commented sa vars.conf)
# -------------------------------------------------
#AUTO_CONFIRM="${AUTO_CONFIRM:-false}"
#FS_TYPE="${FS_TYPE:-btrfs}"

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
