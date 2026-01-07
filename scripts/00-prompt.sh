#!/usr/bin/env bash

echo "=== ARCH LINUX INSTALLER ==="
lsblk
echo

# Prompt only for EFI_PART and ARCH_PART
read -rp "EFI partition (e.g. nvme0n1p1 or vda1 sda1): " EFI_PART
read -rp "Arch partition (WILL BE ERASED): " ARCH_PART
read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -rp "Timezone [Asia/Manila]: " TIMEZONE
TIMEZONE=${TIMEZONE:-Asia/Manila}

# Prefix /dev/ if missing
[[ $EFI_PART != /dev/* ]] && EFI_PART="/dev/$EFI_PART"
[[ $ARCH_PART != /dev/* ]] && ARCH_PART="/dev/$ARCH_PART"

echo
echo "⚠  CONFIRMATION"
echo "EFI  : $EFI_PART (KEEP)"
echo "ARCH : $ARCH_PART (ERASE)"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1
