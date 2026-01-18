run_copy_install_script(){
    # Copy  scripts into the new system
cp -r "$ROOT_DIR" /mnt/root/$ROOT_DIR

}


run_chroot(){
# Run all chroot scripts numerically
for script in /mnt/root/$ROOT_DIR/04-configure-system/[0-9][0-9]*.sh; do
    arch-chroot /mnt "/root/$ROOT_DIR/$(basename "$script")"
done    
}