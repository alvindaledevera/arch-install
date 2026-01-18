run_copy_install_script(){
    # Copy  scripts into the new system
cp -r "$ROOT_DIR" "/mnt/root/arch-install"

}


run_chroot() {
    arch-chroot /mnt /bin/bash -euo pipefail <<'EOF'
# Make sure scripts are executable
chmod +x /root/arch-install/04-configure-system/*.sh

# Run scripts in order
for script in /root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
    /bin/bash "$script"
done
EOF
}