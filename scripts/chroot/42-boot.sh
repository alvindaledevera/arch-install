#!/usr/bin/env bash
ARCH_PART="$1"

sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

bootctl install

UUID=$(blkid -s UUID -o value "$ARCH_PART")

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options rd.luks.name=$UUID=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
EOF

cat <<EOF > /boot/loader/loader.conf
default arch
timeout 5
editor no
EOF
