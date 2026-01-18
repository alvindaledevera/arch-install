#!/usr/bin/env bash
set -euo pipefail

CHROOT_DIR="/mnt"
INSTALL_DIR="/root/arch-install"
VARS_FILE="/vars.conf"

# -------------------------------------------------
# Run arbitrary command inside chroot
# -------------------------------------------------
run_in_chroot() {
    arch-chroot "$CHROOT_DIR" "$@"
}

# -------------------------------------------------
# Run a script inside chroot with full environment
# -------------------------------------------------
run_chroot_script() {
    local script="$1"

    if [[ ! -f "$script" ]]; then
        echo "ERROR: Chroot script not found: $script"
        exit 1
    fi

    arch-chroot "$CHROOT_DIR" /bin/bash -euo pipefail -c "
        # -----------------------------------------
        # Load vars.conf (single source of truth)
        # -----------------------------------------
        if [[ -f '$VARS_FILE' ]]; then
            source '$VARS_FILE'
        else
            echo 'WARN: /vars.conf not found inside chroot'
        fi

        # -----------------------------------------
        # Load installer libraries
        # -----------------------------------------
        for lib in '$INSTALL_DIR'/lib/*.sh; do
            source \"\$lib\"
        done

        # -----------------------------------------
        # Execute the script
        # -----------------------------------------
        source '$script'
    "
}
