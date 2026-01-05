#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/scripts/00-prompt.sh"
source "$SCRIPT_DIR/scripts/01-checks.sh"
source "$SCRIPT_DIR/scripts/10-luks-btrfs.sh"
source "$SCRIPT_DIR/scripts/20-mount.sh"
source "$SCRIPT_DIR/scripts/30-base.sh"
source "$SCRIPT_DIR/scripts/40-chroot.sh"