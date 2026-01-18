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
# Run a script inside chroot with env + vars.conf
# Ensures /dev, /proc, /sys, /run are mounted so passwd works
# -------------------------------------------------
run_chroot_script() {
    local script="$1"

    if [[ ! -f "$CHROOT_DIR/$script" ]]; then
        echo "ERROR: Chroot script not found: $script"
        exit 1
    fi

    echo "[INFO] Running script inside chroot: $script"

    # Mount pseudo-filesystems if not already mounted
    mountpoint -q "$CHROOT_DIR/proc" || mount -t proc /proc "$CHROOT_DIR/proc"
    mountpoint -q "$CHROOT_DIR/sys" || mount --rbind /sys "$CHROOT_DIR/sys"
    mountpoint -q "$CHROOT_DIR/dev" || mount --rbind /dev "$CHROOT_DIR/dev"
    mountpoint -q "$CHROOT_DIR/run" || mount --rbind /run "$CHROOT_DIR/run"

    # Run script interactively inside chroot
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

    echo "[INFO] Finished script: $script"
}
