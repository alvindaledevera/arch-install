#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# Chroot utilities for Arch Linux installer
# ==================================================

CHROOT_DIR="/mnt"
CHROOT_INSTALL_DIR="/root/arch-install"
VARS_FILE="$CHROOT_INSTALL_DIR/vars.conf"

# -------------------------------------------------
# Run an arbitrary command inside chroot
# Example: run_in_chroot ls /root
# -------------------------------------------------
run_in_chroot() {
    arch-chroot "$CHROOT_DIR" "$@"
}

# -------------------------------------------------
# Run all scripts in a directory inside chroot
# Loops through each script once, sources vars.conf and libraries first
# Example: run_chroot_dir "04-configure-system"
# -------------------------------------------------
run_chroot_dir() {
    local dir="$1"   # e.g., "04-configure-system"
    local chroot_dir="$CHROOT_INSTALL_DIR/$dir"

    arch-chroot "$CHROOT_DIR" /bin/bash -euo pipefail <<'EOF'
# Inside chroot now

CHROOT_INSTALL_DIR="/root/arch-install"
VARS_FILE="$CHROOT_INSTALL_DIR/vars.conf"

# -------------------------------------------------
# Load vars.conf if it exists
# -------------------------------------------------
if [[ -f "$VARS_FILE" ]]; then
    source "$VARS_FILE"
else
    echo "WARN: vars.conf not found inside chroot"
fi

# -------------------------------------------------
# Load shared libraries
# -------------------------------------------------
for lib in "$CHROOT_INSTALL_DIR/lib/"*.sh; do
    source "$lib"
done

# -------------------------------------------------
# Loop through all scripts in the target directory
# -------------------------------------------------
TARGET_DIR="$CHROOT_INSTALL_DIR/'"$dir"'"
for script in "$TARGET_DIR"/*.sh; do
    [[ -x "$script" ]] || chmod +x "$script"
    ui_step "Running $(basename "$script")"
    # Use bash -e to avoid breaking interactive scripts
    /bin/bash "$script"
done
EOF
}
