#!/usr/bin/env bash

echo "=== ARCH LINUX INSTALLER ==="
lsblk
echo

read -rp "Disk (e.g. /dev/nvme0n1): " DISK
read -rp "EFI partition (e.g. /dev/nvme0n1p1): " EFI_PART
read -rp "Arch partition (WILL BE ERASED): " ARCH_PART

read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME

read -rp "Timezone [Asia/Manila]: " TIMEZONE
TIMEZONE=${TIMEZONE:-Asia/Manila}

echo
echo "⚠️  CONFIRMATION"
echo "EFI  : $EFI_PART (KEEP)"
echo "ARCH : $ARCH_PART (ERASE)"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1
