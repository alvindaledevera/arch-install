#!/usr/bin/env bash
set -euo pipefail

ui_banner "Updating pacman mirrors"

# Install reflector if missing
if ! command -v reflector &>/dev/null; then
    ui_info "Installing reflector..."
    pacman -Sy --noconfirm reflector
fi

# Detect country via IP
COUNTRY="$(curl -fsSL https://ipapi.co/country || true)"
COUNTRY="${COUNTRY:-all}"
ui_info "Detected country: $COUNTRY"

# Run reflector to generate mirrorlist directly
ui_info "Generating optimal mirrorlist with reflector..."
if [[ "$COUNTRY" != "all" ]] && reflector --country "$COUNTRY" --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist 2>/dev/null; then
    ui_success "Mirrorlist updated for country: $COUNTRY"
else
    ui_warn "Failed to fetch mirrors for $COUNTRY or country set to all, using global HTTPS mirrors..."
    reflector --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
    ui_success "Global mirrorlist updated"
fi

# Enable parallel downloads in pacman.conf (Arch Wiki standard)
ui_step "Enabling parallel downloads in pacman.conf..."
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    sed -i '/^\[options\]/a ParallelDownloads = 5' /etc/pacman.conf
fi

ui_success "Parallel downloads enabled (ParallelDownloads = 5)"
