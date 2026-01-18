run_copy_install_script(){
    # Copy  scripts into the new system
cp -r "$ROOT_DIR" "/mnt/root/arch-install"

}


run_chroot(){
# Run all chroot scripts numerically
for script in /mnt/root/arch-install/04-configure-system/[0-9][0-9]*.sh; do
    arch-chroot /mnt "/root/arch-install/04-configure-system/$(basename "$script")"
done    
}