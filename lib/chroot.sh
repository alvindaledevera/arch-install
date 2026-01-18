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
# Run all scripts in a directory inside chroot
# -------------------------------------------------
run_chroot_dir() {
    local dir="$1"   # relative path inside installer, e.g., 04-configure-system
    local chroot_dir="$CHROOT_INSTALL_DIR/$dir"

    arch-chroot "$CHROOT_DIR" /bin/bash -euo pipefail -c "
        set -euo pipefail

        # -------------------------------------------------
        # Load vars.conf if present
        # -------------------------------------------------
        if [[ -f $VARS_FILE ]]; then
            source $VARS_FILE
        else
            echo 'WARN: vars.conf not found inside chroot'
        fi

        # -------------------------------------------------
        # Load shared libraries
        # -------------------------------------------------
        for lib in $CHROOT_INSTALL_DIR/lib/*.sh; do
            source \"\$lib\"
        done

        # -------------------------------------------------
        # Loop over scripts in this directory
        # -------------------------------------------------
        for script in $chroot_dir/*.sh; do
            [[ -x \"\$script\" ]] || chmod +x \"\$script\"
            ui_step \"Running \$(basename \$script)\"
            source \"\$script\"
        done
    "
}
