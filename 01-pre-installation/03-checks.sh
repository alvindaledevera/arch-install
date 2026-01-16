#!/usr/bin/env bash
set -euo pipefail

ui_banner "Pre-installation: System checks"

# Root check (double safety)
if [[ $EUID -ne 0 ]]; then
  ui_error "Must be run as root"
  exit 1
fi

# UEFI check
if [[ ! -d /sys/firmware/efi ]]; then
  ui_error "System not booted in UEFI mode"
  exit 1
fi

# Internet check
ui_step "Checking internet connectivity"
if ! ping -c 1 ping.archlinux.org &>/dev/null; then
  ui_error "No internet connection"
  exit 1
fi


ui_success "All checks passed"
