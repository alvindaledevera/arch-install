#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# chroot.sh – copy installer and run all chroot scripts
# ==================================================

# -----------------------------
# Copy full arch-install into target system
# -----------------------------
run_copy_install_script() {
    echo "[INFO] Copying arch-install into target system..."
    cp -a "$ROOT_DIR" /mnt/root/arch-install
}

# -----------------------------
# Run chroot configuration
# -----------------------------
run_chroot() {
    arch-chroot /mnt /bin/bash <<'EOF'
    ...
    for script in /root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
        ui_step "$(basename "$script")"
        source "$script"
    done
EOF
}