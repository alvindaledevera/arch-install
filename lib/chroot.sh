#!/usr/bin/env bash
set -euo pipefail

run_copy_install_script() {
    echo "[INFO] Copying arch-install into target system"
    cp -a "$ROOT_DIR" /mnt/root/arch-install
}

run_chroot() {
    arch-chroot /mnt /bin/bash <<'EOF'
set -euo pipefail

# ----------------------------------
# Load installer variables
# ----------------------------------
if [[ -f /root/arch-install/vars.conf ]]; then
    source /root/arch-install/vars.conf
else
    echo "[WARN] vars.conf not found in chroot"
fi

# ----------------------------------
# Load shared libraries (UI, log, etc.)
# ----------------------------------
for lib in /root/arch-install/lib/*.sh; do
    source "$lib"
done

ui_banner "Running chroot system configuration"

# ----------------------------------
# Ensure scripts are executable
# ----------------------------------
chmod +x /root/arch-install/04-configure-system/*.sh

# ----------------------------------
# Run scripts in order
# ----------------------------------
for script in /root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
    ui_step "$(basename "$script")"
    /bin/bash "$script"
done

ui_success "Chroot configuration complete"
EOF
}
