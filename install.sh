#!/usr/bin/env bash
set -e

# Repo root (single source of truth)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR

# Load UI helpers once
source "$ROOT_DIR/scripts/lib/ui.sh"

echo "=== ARCH LINUX INSTALLER ==="

chmod +x "$ROOT_DIR"/scripts/*.sh
chmod +x "$ROOT_DIR"/scripts/chroot/*.sh

# Wrapper to auto-print stage
run_stage() {
  print_stage "$1"
  source "$1"
}

run_stage "$ROOT_DIR/scripts/00-prompt.sh"
run_stage "$ROOT_DIR/scripts/01-checks.sh"
run_stage "$ROOT_DIR/scripts/10-luks-btrfs.sh"
run_stage "$ROOT_DIR/scripts/20-mount.sh"
run_stage "$ROOT_DIR/scripts/30-base.sh"
run_stage "$ROOT_DIR/scripts/40-chroot.sh"

echo "✅ Installation finished!"
