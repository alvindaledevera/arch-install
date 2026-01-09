#!/usr/bin/env bash
set -e

# -----------------------------
# 42-boot.sh - Configure bootloader and initramfs
# -----------------------------

echo "⏱ Configuring mkinitcpio hooks and generating initramfs..."

# Backup existing mkinitcpio.conf just in case
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak

# Optional modules
MODULES=(btrfs atkbd)

# Update HOOKS and MODULES
sed -i "s/^HOOKS=.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)/" /etc/mkinitcpio.conf
sed -i "s/^MODULES=.*/MODULES=(${MODULES[*]})/" /etc/mkinitcpio.conf

# Regenerate initramfs for all kernels
mkinitcpio -P

echo "⏱ Installing systemd-boot..."
bootctl install

# Get UUID of the LUKS-encrypted root partition
UUID=$(blkid -s UUID -o value "$ARCH_PART")

# Write systemd-boot entry
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options rd.luks.name=$UUID=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
EOF

# Configure loader
cat <<EOF > /boot/loader/loader.conf
default arch
timeout 5
editor no
EOF

echo "✅ Bootloader and initramfs configured!"
