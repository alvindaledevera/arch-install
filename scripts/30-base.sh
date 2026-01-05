#!/usr/bin/env bash

pacstrap /mnt base linux linux-firmware btrfs-progs vim sudo git nano \
timeshift zram-generator

genfstab -U /mnt >> /mnt/etc/fstab
