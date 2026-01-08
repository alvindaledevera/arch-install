#!/usr/bin/env bash
set -e

# Copy chroot scripts into installed system
cp -r "$ROOT_DIR/scripts/chroot" /mnt/root/chroot
chmod +x /mnt/root/chroot/*.sh

# -------------------------
# Export variables to chroot
# -------------------------
arch-chroot /mnt /bin/bash -c "export EFI_PART='$EFI_PART' ARCH_PART='$ARCH_PART' HOSTNAME='$HOSTNAME' USERNAME='$USERNAME' KEYMAP='$KEYMAP' LOCALE='$LOCALE' TIMEZONE='$TIMEZONE'; \
for script in /root/chroot/[0-9][0-9]*.sh; do
    bash \"\$script\"
done"

echo "✅ Chroot scripts completed"
