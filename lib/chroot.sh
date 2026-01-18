#!/usr/bin/env bash
set -euo pipefail

CHROOT_DIR="/mnt"
CHROOT_INSTALL_DIR="/root/arch-install"
VARS_FILE="$CHROOT_INSTALL_DIR/vars.conf"

# -------------------------------------------------
# Run arbitrary command inside chroot
# -------------------------------------------------
run_in_chroot() {
    arch-chroot "$CHROOT_DIR" "$@"
}

# -------------------------------------------------
# Run a script inside chroot
# -------------------------------------------------
run_chroot_script() {
    local script_path="$1"   # path relative to chroot: /root/arch-install/...
    
    # Ensure the script exists in the chroot
    if [[ ! -f "$CHROOT_DIR$script_path" ]]; then
        echo "ERROR: Chroot script not found: $CHROOT_DIR$script_path"
        exit 1
    fi

    echo "[INFO] Running script inside chroot: $script_path"

    # Run inside chroot
    arch-chroot "$CHROOT_DIR" /bin/bash -euo pipefail -c "
        # Load vars.conf if exists
        if [[ -f $VARS_FILE ]]; then
            source $VARS_FILE
        else
            echo 'WARN: vars.conf not found inside chroot'
        fi

        # Load libraries
        for lib in $CHROOT_INSTALL_DIR/lib/*.sh; do
            source \"\$lib\"
        done

        # Run the target script
        /bin/bash $script_path
    "
}
