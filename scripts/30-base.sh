#!/usr/bin/env bash

pacstrap /mnt base linux linux-firmware \
btrfs-progs vim sudo git \
systemd-networkd systemd-resolved \
timeshift zram-generator

genfstab -U /mnt >> /mnt/etc/fstab
