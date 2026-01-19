#!/usr/bin/env bash
set -euo pipefail

run_copy_install_script() {
    echo "[INFO] Copying arch-install into target system"
    cp -a "$ROOT_DIR" /mnt/root/arch-install
}

run_chroot() {
    arch-chroot /mnt /bin/bash <<'EOF'
set -euo pipefail

# Load vars
if [[ -f /root/arch-install/vars.conf ]]; then
    source /root/arch-install/vars.conf
    export FS_TYPE USE_LUKS USERNAME KEYMAP TIMEZONE HOSTNAME
fi

# Load UI/log helpers
for lib in /root/arch-install/lib/*.sh; do
    source "$lib"
done

ui_banner "Running chroot system configuration"

# Make sure scripts are executable
chmod +x /root/arch-install/04-configure-system/*.sh

# Run scripts in order
for script in /root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
    ui_step "$(basename "$script")"
    source "$script"
done

ui_success "Chroot configuration complete"
EOF
}
