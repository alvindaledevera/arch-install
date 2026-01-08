#!/usr/bin/env bash
set -e

# -----------------------------
# Copy full arch-install folder into chroot
# -----------------------------
cp -r "$ROOT_DIR" /mnt/root/arch-install

# Export variables for use inside chroot
arch-chroot /mnt /bin/bash -c "export EFI_PART='$EFI_PART' \
ARCH_PART='$ARCH_PART' \
HOSTNAME='$HOSTNAME' \
USERNAME='$USERNAME' \
KEYMAP='$KEYMAP' \
LOCALE='$LOCALE' \
TIMEZONE='$TIMEZONE' && \
bash -c 'for script in /root/arch-install/scripts/chroot/[0-9][0-9]*.sh; do
    source /root/arch-install/scripts/lib/ui.sh
    print_stage \$script
    source \$script
done'"
