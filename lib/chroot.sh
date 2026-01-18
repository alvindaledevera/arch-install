#!/usr/bin/env bash
set -euo pipefail

CHROOT_DIR="/mnt"
CHROOT_INSTALL_DIR="/root/arch-install"
VARS_FILE="$CHROOT_INSTALL_DIR/vars.conf"

# -------------------------------------------------
# Copy installer scripts into target system
# -------------------------------------------------
run_copy_install_script() {
    ui_section "Copy arch-install into target system"

    if [[ ! -d "$CHROOT_DIR$CHROOT_INSTALL_DIR" ]]; then
        ui_info "Copying installer scripts to $CHROOT_INSTALL_DIR in chroot..."
        cp -a "$ROOT_DIR" "$CHROOT_DIR$CHROOT_INSTALL_DIR"
    else
        ui_warn "arch-install already exists in target system, skipping copy"
    fi
}

# -------------------------------------------------
# Run all scripts in 04-configure-system inside chroot
# -------------------------------------------------
run_chroot() {
    ui_section "Running 04-configure-system scripts inside chroot"

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
# Load shared libraries for UI, logging, etc.
# -------------------------------------------------
for lib in $CHROOT_INSTALL_DIR/lib/*.sh; do
    source "\$lib"
done

# -------------------------------------------------
# Make all scripts executable
# -------------------------------------------------
chmod +x $CHROOT_INSTALL_DIR/04-configure-system/*.sh

# -------------------------------------------------
# Run scripts in numerical order
# -------------------------------------------------
for script in $CHROOT_INSTALL_DIR/04-configure-system/[0-9][0-9]*.sh; do
    ui_step "Running \$(basename \$script)"
    source "\$script"
done
EOF
}
