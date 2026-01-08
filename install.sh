#!/usr/bin/env bash
set -e

# Root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR

# Load UI helpers
source "$ROOT_DIR/scripts/lib/ui.sh"

# Make scripts executable
chmod +x "$ROOT_DIR"/scripts/*.sh
chmod +x "$ROOT_DIR"/scripts/chroot/*.sh
chmod +x "$ROOT_DIR"/scripts/lib/*.sh

# Wrapper to auto-print stage
run_stage() {
    print_stage "$1"
    source "$1"
}

# -------------------------
# Installation stages
# -------------------------
run_stage "$ROOT_DIR/scripts/00-prompt.sh"     # user input
run_stage "$ROOT_DIR/scripts/01-checks.sh"     # preflight checks
run_stage "$ROOT_DIR/scripts/05-time.sh"       # timezone & NTP
run_stage "$ROOT_DIR/scripts/10-luks-btrfs.sh" # partitions, encryption
run_stage "$ROOT_DIR/scripts/20-mount.sh"      # mount Btrfs subvols
run_stage "$ROOT_DIR/scripts/30-base.sh"       # install base packages
run_stage "$ROOT_DIR/scripts/40-chroot.sh"     # chroot & configure system

echo "✅ Installation finished!"
