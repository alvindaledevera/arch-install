#!/usr/bin/env bash
set -euo pipefail

ui_banner "Pre-installation: Confirmation"

ui_warn "This will ERASE disk: $DISK"
ui_step "Hostname : $HOSTNAME"
ui_step "Timezone : $TIMEZONE"
ui_step "Locale   : $LOCALE"
ui_step "User     : $USERNAME"
ui_step "Filesystem: $FS_TYPE"

if [[ "${AUTO_CONFIRM}" != "true" ]]; then
  read -rp "Continue installation? [y/N]: " ans
  [[ "$ans" == "y" || "$ans" == "Y" ]] || {
    ui_error "Installation aborted by user"
    exit 1
  }
fi

ui_success "Confirmation accepted"
