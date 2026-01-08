#!/usr/bin/env bash
set -e

# Export variables for chroot scripts
export EFI_PART ARCH_PART HOSTNAME USERNAME KEYMAP LOCALE TIMEZONE

# Copy chroot scripts and lib folder
cp -r "$ROOT_DIR/scripts/chroot" /mnt/root/chroot
cp -r "$ROOT_DIR/scripts/lib" /mnt/root/chroot/lib

# Run all chroot scripts numerically with automatic stage print
for script in /mnt/root/chroot/[0-9][0-9]*.sh; do
    arch-chroot /mnt /bin/bash -c "
        source /root/chroot/lib/ui.sh
        print_stage '$script'
        bash '$script'
    "
done

echo "✅ INSTALL COMPLETE"
