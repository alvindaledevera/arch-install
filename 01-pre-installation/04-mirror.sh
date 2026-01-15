#!/usr/bin/env bash
set -euo pipefail

ui_banner "Updating pacman mirrors"

# Install reflector if missing
if ! command -v reflector &>/dev/null; then
    pacman -Sy --noconfirm reflector python
fi

# Detect country (fallback to global if needed)
COUNTRY="$(curl -fsSL https://ipapi.co/country || true)"
COUNTRY="${COUNTRY:-all}"

ui_info "Detected country: $COUNTRY"

# Fetch top 10 mirrors
TMP_MIRRORLIST="/tmp/mirrorlist.tmp"
reflector --country "$COUNTRY" --protocol https --latest 10 --sort rate --save "$TMP_MIRRORLIST" || \
reflector --country all --protocol https --latest 10 --sort rate --save "$TMP_MIRRORLIST"

mapfile -t MIRRORS < <(awk '{print $1}' "$TMP_MIRRORLIST")

# Interactive selection
ui_step "Select a mirror to use:"
PS3="Enter the number: "
select MIRROR in "${MIRRORS[@]}"; do
    [[ -n "$MIRROR" ]] || { ui_warn "Invalid selection"; continue; }
    echo "Server = $MIRROR" > /etc/pacman.d/mirrorlist
    ui_success "Mirrorlist updated to $MIRROR"
    break
done

# Enable parallel downloads
ui_step "Enabling parallel downloads..."
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    echo 'ParallelDownloads = 5' >> /etc/pacman.conf
fi
ui_success "Parallel downloads enabled"
