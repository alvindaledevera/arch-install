#!/usr/bin/env bash

cryptsetup luksFormat "$ARCH_PART"
cryptsetup open "$ARCH_PART" cryptroot

mkfs.btrfs /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt