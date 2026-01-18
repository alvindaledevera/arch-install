#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# Paths
# -------------------------------------------------
CHROOT_DIR="/mnt"
CHROOT_INSTALL_DIR="/root/arch-install"
CONFIG_FILE="$CHROOT_INSTALL_DIR/vars.conf"

# -------------------------------------------------
# Copy full installer into chroot
# -------------------------------------------------
run_copy_install_script() {
    echo "Copying arch-install folder into chroot..."
    cp -r "$ROOT_DIR" "$CHROOT_DIR$CHROOT_INSTALL_DIR"
}

# -------------------------------------------------
# Run all 04-configure-system scripts inside chroot
# -------------------------------------------------
run_chroot() {
    echo "Entering chroot and running configuration scripts..."

    arch-chroot "$CHROOT_DIR" /bin/bash -euo pipefail <<'EOF'
# -----------------------------
# Load installer config
# -----------------------------
if [[ -f /root/arch-install/vars.conf ]]; then
    source /root/arch-install/vars.conf
else
    echo "WARN: vars.conf not found inside chroot"
fi

# -----------------------------
# Load UI helpers
# -----------------------------
for lib in /root/arch-install/lib/*.sh; do
    source "$lib"
done

# -----------------------------
# Export important variables
# -----------------------------
export EFI_PART="${EFI_PART:-}"
export ROOT_PART="${ROOT_PART:-}"
export HOSTNAME="${HOSTNAME:-}"
export USERNAME="${USERNAME:-}"
export KEYMAP="${KEYMAP:-}"
export LOCALE="${LOCALE:-}"
export TIMEZONE="${TIMEZONE:-}"
export USE_LUKS="${USE_LUKS:-N}"
export FS_TYPE="${FS_TYPE:-}"

# -----------------------------
# Banner
# -----------------------------
ui_banner "Running chroot configuration scripts"

# -----------------------------
# Make scripts executable and run them in order
# -----------------------------
for script in /root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
    chmod +x "$script"
    ui_step "Running $(basename "$script")"
    source "$script"
done
EOF
}
