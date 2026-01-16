#!/usr/bin/env bash
set -euo pipefail

CHROOT_DIR="/mnt"

# Run arbitrary command inside chroot
run_in_chroot() {
    arch-chroot "$CHROOT_DIR" "$@"
}

# Run a script inside chroot, ensuring libraries are loaded
run_chroot_script() {
    local script="$1"

    if [[ ! -f "$script" ]]; then
        echo "Chroot script not found: $script"
        exit 1
    fi

    arch-chroot "$CHROOT_DIR" /bin/bash -c "
        for lib in /root/arch-install/lib/*.sh; do
            source \"\$lib\"
        done
        source \"$script\"
    "
}
