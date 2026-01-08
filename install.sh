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
# Dynamic installation stages
# -------------------------
for script in $(ls "$ROOT_DIR/scripts"/*.sh | sort); do
    # Skip lib scripts
    [[ $script == *"/lib/"* ]] && continue
    run_stage "$script"
done

echo "✅ Installation finished!"
