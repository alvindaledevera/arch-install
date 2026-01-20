#!/usr/bin/env bash
set -euo pipefail

ui_banner "Base System Installation (pacstrap)"

# -------------------------------------------------
# Sanity checks
# -------------------------------------------------
[[ -d /mnt ]] || {
    ui_error "/mnt does not exist"
    exit 1
}

mountpoint -q /mnt || {
    ui_error "/mnt is not mounted"
    exit 1
}

# -------------------------------------------------
# Base packages
# -------------------------------------------------
BASE_PKGS=(
    base
    linux
    linux-firmware
    linux-headers

    ## Essentials
    btrfs-progs
    base-devel
    timeshift
    #sudo
    #vim
    nano
    git
    #curl
    #wget

    ## Networking
    #networkmanager
    #openssh
)

ui_info "Installing base packages to /mnt"
pacstrap -K /mnt "${BASE_PKGS[@]}"

ui_success "Base system installed successfully"
