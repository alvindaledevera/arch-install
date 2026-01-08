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
chmod +x "$ROOT_DIR"/scripts/user/*.sh

# Wrapper to auto-print stage
run_stage() {
    print_stage "$1"
    source "$1"
}

# -------------------------
# Installation stages
# -------------------------
for script in "$ROOT_DIR"/scripts/*.sh; do
    # Skip lib scripts
    [[ $script == *"/lib/"* ]] && continue
    run_stage "$script"
done

arch-chroot /mnt /usr/bin/runuser -u "$USERNAME" -- bash -c '
set -e
source /home/'"$USERNAME"'/arch-install/scripts/lib/ui.sh

for script in /home/'"$USERNAME"'/arch-install/scripts/user/*.sh; do
    [[ $script == */lib/* ]] && continue
    print_stage "$(basename "$script")"
    bash "$script"
done
'

echo "✅ Installation finished!"
