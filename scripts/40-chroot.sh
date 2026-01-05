#!/usr/bin/env bash

cp -r scripts/chroot /mnt/root/chroot
arch-chroot /mnt /root/chroot/41-system.sh \
"$HOSTNAME" "$TIMEZONE"

arch-chroot /mnt /root/chroot/42-boot.sh "$ARCH_PART"
arch-chroot /mnt /root/chroot/43-network.sh
arch-chroot /mnt /root/chroot/44-zram.sh
arch-chroot /mnt /root/chroot/45-user.sh "$USERNAME"

echo "✅ INSTALL COMPLETE"
