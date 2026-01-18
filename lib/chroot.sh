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
# Run script inside chroot with env + vars.conf
# -------------------------------------------------
run_chroot_script() {
    local script="$1"

    if [[ ! -f "$CHROOT_DIR/$script" ]]; then
        echo "ERROR: Chroot script not found: $script"
        exit 1
    fi

    arch-chroot "$CHROOT_DIR" /bin/bash -euo pipefail <<EOF
# -------------------------------------------------
# Load vars.conf if present
# -------------------------------------------------

if [[ -f "$VARS_FILE" ]]; then
    source "$VARS_FILE"
else
    echo "WARN: vars.conf not found inside chroot"
fi

# -------------------------------------------------
# Load shared libraries
# -------------------------------------------------
for lib in $CHROOT_INSTALL_DIR/lib/*.sh; do
    source "\$lib"
done

# -------------------------------------------------
# Run actual script
# -------------------------------------------------
source "$script"
EOF
}
