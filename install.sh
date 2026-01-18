#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# Arch Linux Install Script (Runner)
# ==================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -----------------------------
# Load installer config (outside chroot)
# -----------------------------
CONFIG_FILE="${ROOT_DIR}/vars.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: vars.conf not found"
    echo "Copy vars.conf.example → vars.conf and edit it"
    exit 1
fi

source "$CONFIG_FILE"

# -----------------------------
# Load libraries
# -----------------------------
for lib in ui log disk pacman chroot; do
    source "${ROOT_DIR}/lib/${lib}.sh"
done

# -----------------------------
# Safety checks
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    ui_error "This script must be run as root"
    exit 1
fi

if [[ ! -d /sys/firmware/efi ]]; then
    ui_error "System not booted in UEFI mode"
    exit 1
fi

# -----------------------------
# Helper: run scripts in a directory (outside chroot)
# -----------------------------
run_dir() {
    local dir="$1"
    ui_section "Running ${dir}"

    for script in "${ROOT_DIR}/${dir}"/*.sh; do
        [[ -x "$script" ]] || chmod +x "$script"
        ui_step "$(basename "$script")"
        source "$script"
    done
}


# ==================================================
# Main installation flow
# ==================================================
ui_banner "Arch Linux Installation Started"

# -----------------------------
# Pre-installation (outside chroot)
# -----------------------------
run_dir "01-pre-installation"

# -----------------------------
# Disk setup (outside chroot)
# -----------------------------
run_dir "02-disk-setup"

# -----------------------------
# Base installation (outside chroot)
# -----------------------------
run_dir "03-installation"


# -----------------------------
# Copy installer into target system before chroot
# -----------------------------
run_copy_install_script

# -----------------------------
# Chroot configuration
# -----------------------------
run_chroot

# -----------------------------
# Post-install scripts (optional)
# -----------------------------
# run_dir "05-post-install"

ui_success "Installation complete! You can reboot now 🚀"
