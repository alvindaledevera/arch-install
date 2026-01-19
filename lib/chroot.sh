#!/usr/bin/env bash
set -euo pipefail

run_copy_install_script() {
    echo "[INFO] Copying arch-install into target system"
    cp -a "$ROOT_DIR" /mnt/root/arch-install
}

run_chroot() {
    echo "[INFO] Running scripts inside chroot"
    
    # Ensure scripts are executable
    chmod +x /mnt/root/arch-install/04-configure-system/*.sh

    # Run each script interactively inside chroot
    for script in /mnt/root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
        echo "[CHROOT] Running $(basename "$script")"
        arch-chroot /mnt /bin/bash -c "/root/arch-install/04-configure-system/$(basename "$script")"
    done

    echo "[INFO] Chroot configuration complete"
}
