#!/usr/bin/env bash
set -e

REPO_DIR="arch-install"
REPO_URL="https://github.com/alvindaledevera/$REPO_DIR.git"

# ----------------------------------------
# SELF-BOOTSTRAP (run only if not in repo)
# ----------------------------------------
if [ ! -d ".git" ]; then
  echo "=== Bootstrapping Arch Installer ==="

  # Ensure network is up
  ping -c1 archlinux.org >/dev/null 2>&1 || {
    echo "❌ Network not available"
    exit 1
  }

  # Install git
  pacman -Sy --noconfirm archlinux-keyring git

  # Clone installer repo
  git clone "$REPO_URL"
  cd "$REPO_DIR"

  # Ensure executable
  chmod +x install.sh

  # Re-run installer from repo
  exec ./install.sh
fi

# ----------------------------------------
# NORMAL INSTALL FLOW
# ----------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== ARCH LINUX INSTALLER ==="

# Make all installer scripts executable
chmod +x "$SCRIPT_DIR"/scripts/*.sh
chmod +x "$SCRIPT_DIR"/scripts/chroot/*.sh

# Source installer scripts
source "$SCRIPT_DIR"/scripts/00-prompt.sh
source "$SCRIPT_DIR"/scripts/01-checks.sh
source "$SCRIPT_DIR"/scripts/10-luks-btrfs.sh
source "$SCRIPT_DIR"/scripts/20-mount.sh
source "$SCRIPT_DIR"/scripts/30-base.sh
source "$SCRIPT_DIR"/scripts/40-chroot.sh

echo "✅ Installation finished!"
