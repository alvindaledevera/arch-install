#!/usr/bin/env bash
USERNAME="$1"

useradd -m -G wheel "$USERNAME"
passwd "$USERNAME"
passwd

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
