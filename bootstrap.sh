#!/usr/bin/env bash
set -e

REPO_DIR="arch-install"
REPO_URL="https://github.com/alvindaledevera/$REPO_DIR.git"

pacman -Sy --noconfirm git


# Clone installer repo
  git clone "$REPO_URL"
  cd "$REPO_DIR"

  # Ensure executable
  chmod +x install.sh

  # Re-run installer from repo
  exec ./install.sh