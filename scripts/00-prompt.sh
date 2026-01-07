#!/usr/bin/env bash
set -e

# -----------------------------
# UI / STAGE HEADER
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
print_stage "$0"

echo "=== ARCH LINUX INSTALLER ==="
lsblk
echo

# -----------------------------
# AUTO-DETECT TIMEZONE
# -----------------------------
TIMEZONE="$(curl --fail -s https://ipapi.co/timezone || true)"
TIMEZONE="${TIMEZONE:-Asia/Manila}"

# -----------------------------
# USER INPUTS
# -----------------------------
read -rp "EFI partition (e.g. nvme0n1p1 or vda1 sda1): " EFI_PART
read -rp "Arch partition (WILL BE ERASED): " ARCH_PART
read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME
read -rp "Timezone [Detected: $TIMEZONE]: " TZ_INPUT
TIMEZONE="${TZ_INPUT:-$TIMEZONE}"

# -----------------------------
# NORMALIZE DEVICE PATHS
# -----------------------------
[[ $EFI_PART != /dev/* ]] && EFI_PART="/dev/$EFI_PART"
[[ $ARCH_PART != /dev/* ]] && ARCH_PART="/dev/$ARCH_PART"

# -----------------------------
# CONFIRMATION
# -----------------------------
echo
echo "⚠  CONFIRMATION"
echo "EFI      : $EFI_PART (KEEP)"
echo "ARCH     : $ARCH_PART (ERASE)"
echo "HOSTNAME : $HOSTNAME"
echo "USERNAME : $USERNAME"
echo "TIMEZONE : $TIMEZONE"
echo

read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1
cd