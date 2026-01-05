#!/usr/bin/env bash
set -e

# -----------------------------
# ARCH LINUX INSTALLER - MAIN
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1️⃣ Prompt user input
source "$SCRIPT_DIR/scripts/00-prompt.sh"

# 2️⃣ Pre-checks
source "$SCRIPT_DIR/scripts/01-checks.sh"

# 3️⃣ LUKS + Btrfs
source "$SCRIPT_DIR/scripts/10-luks-btrfs.sh"

# 4️⃣ Mount
source "$SCRIPT_DIR/scripts/20-mount.sh"

# 5️⃣ Base system install
source "$SCRIPT_DIR/scripts/30-base.sh"

# 6️⃣ Chroot configuration
source "$SCRIPT_DIR/scripts/40-chroot.sh"

# 7️⃣ Final message
echo
echo "✅ Installation script completed."
echo "🔹 Arch Linux base installed at /mnt"
echo "🔹 Remember to configure systemd-boot or GRUB next."
