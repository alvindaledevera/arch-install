#!/usr/bin/env bash
set -e

echo "=== ARCH LINUX INSTALLER ==="
lsblk
echo

# -----------------------------
# Auto-detect timezone
# -----------------------------
TIMEZONE="$(curl --fail -s https://ipapi.co/timezone || true)"
TIMEZONE="${TIMEZONE:-Asia/Manila}"

# -----------------------------
# User Inputs
# -----------------------------
read -rp "EFI partition (e.g. nvme0n1p1 or vda1 sda1): " EFI_PART
read -rp "Arch partition (WILL BE ERASED! nvme0n1p2 or vda2 sda2:)" ARCH_PART
read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -rp "Keyboard layout [us]: " KEYMAP
KEYMAP="${KEYMAP:-us}"
read -rp "Locale [en_US.UTF-8]: " LOCALE
LOCALE="${LOCALE:-en_US.UTF-8}"
read -rp "Timezone [Detected: $TIMEZONE]: " TZ_INPUT
TIMEZONE="${TZ_INPUT:-$TIMEZONE}"

# Prefix /dev/ if missing
[[ $EFI_PART != /dev/* ]] && EFI_PART="/dev/$EFI_PART"
[[ $ARCH_PART != /dev/* ]] && ARCH_PART="/dev/$ARCH_PART"

# -----------------------------
# Confirm
# -----------------------------
echo
echo "⚠ CONFIRMATION"
echo "EFI      : $EFI_PART (KEEP)"
echo "ARCH     : $ARCH_PART (ERASE)"
echo "HOSTNAME : $HOSTNAME"
echo "USERNAME : $USERNAME"
echo "KEYMAP   : $KEYMAP"
echo "LOCALE   : $LOCALE"
echo "TIMEZONE : $TIMEZONE"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

# Export variables for chroot scripts
export EFI_PART ARCH_PART HOSTNAME USERNAME KEYMAP LOCALE TIMEZONE

echo "✅ Variables exported for chroot scripts"
