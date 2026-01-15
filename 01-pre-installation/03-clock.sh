#!/usr/bin/env bash
set -euo pipefail

ui_banner "Pre-installation: System clock"

ui_step "Enabling NTP"
timedatectl set-ntp true

ui_step "Current time status:"
timedatectl status | sed -n '1,5p'

ui_success "System clock configured"
