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
    echo "[INFO] Entering chroot to run system configuration scripts..."

    arch-chroot /mnt /root/arch-install/lib/run_chroot_scripts.sh
}
