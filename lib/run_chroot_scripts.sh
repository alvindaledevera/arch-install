#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------
# Load UI helpers once
# ----------------------------------
source /root/arch-install/lib/ui.sh

ui_banner "Running chroot system configuration"

# ----------------------------------
# Load installer variables if available
# ----------------------------------
if [[ -f /root/arch-install/vars.conf ]]; then
    source /root/arch-install/vars.conf
else
    echo "[WARN] vars.conf not found in chroot"
fi

# ----------------------------------
# Ensure scripts are executable
# ----------------------------------
chmod +x /root/arch-install/04-configure-system/*.sh

# ----------------------------------
# Run scripts in order
# ----------------------------------
for script in /root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
    ui_step "Running $(basename "$script")"
    source "$script"
done

ui_success "Chroot configuration complete ✅"
