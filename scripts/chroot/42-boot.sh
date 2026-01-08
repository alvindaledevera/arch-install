#!/usr/bin/env bash
set -e

# -----------------------------
# 42-boot.sh - Configure systemd-boot with LUKS+Btrfs
# -----------------------------

# Ensure EFI partition is mounted
if [ ! -d /boot ]; then
    echo "❌ /boot not mounted. Please mount EFI partition to /boot."
    exit 1
fi

echo "⏱ Configuring mkinitcpio hooks..."
# Add systemd + sd-encrypt hooks for LUKS
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf

echo "⏱ Generating initramfs..."
mkinitcpio -P

echo "⏱ Installing systemd-boot..."
bootctl install

# Get UUID of encrypted root
UUID=$(blkid -s UUID -o value "$ARCH_PART")
if [ -z "$UUID" ]; then
    echo "❌ Failed to get UUID of $ARCH_PART"
    exit 1
fi

echo "⏱ Creating systemd-boot entry for Arch Linux..."
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options rd.luks.name=$UUID=cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
EOF

echo "⏱ Creating loader configuration..."
cat <<EOF > /boot/loader/loader.conf
default arch
timeout 5
editor no
EOF

echo "✅ systemd-boot configured successfully!"
