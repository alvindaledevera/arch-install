#!/usr/bin/env bash
set -euo pipefail

ui_banner "Updating pacman mirrors (Post-chroot)"

# Install reflector + Python if missing
if ! command -v reflector &>/dev/null; then
    pacman -Sy --noconfirm reflector python
fi

# Detect country via IP
COUNTRY="$(curl -fsSL https://ipapi.co/country || true)"
COUNTRY="${COUNTRY:-all}"
ui_info "Detected country: $COUNTRY"

# Fetch top 10 fastest mirrors for detected country
mapfile -t MIRRORS < <(
    reflector --country "$COUNTRY" --protocol https --latest 10 --sort rate --save /tmp/mirrorlist.tmp \
    && awk '{print $1}' /tmp/mirrorlist.tmp
)

# Fallback to global if no mirrors found
if [ ${#MIRRORS[@]} -eq 0 ]; then
    ui_warn "No mirrors found for $COUNTRY, using global mirrors..."
    mapfile -t MIRRORS < <(
        reflector --country all --protocol https --latest 10 --sort rate --save /tmp/mirrorlist.tmp \
        && awk '{print $1}' /tmp/mirrorlist.tmp
    )
fi

# Let user select mirror
ui_step "Select a mirror to use:"
PS3="Enter number: "
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
