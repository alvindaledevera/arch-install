#!/usr/bin/env bash
set -euo pipefail

ui_banner "Pre-installation: Mirrorlist"

ui_step "Installing reflector"
pacman -Sy --noconfirm reflector

ui_step "Updating mirrorlist"
reflector \
  --country Philippines,Japan,Singapore \
  --protocol https \
  --latest 20 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist

ui_success "Mirrorlist updated"
