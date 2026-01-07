#!/usr/bin/env bash
set -e

REPO_DIR="arch-install"
REPO_URL="https://github.com/alvindaledevera/$REPO_DIR.git"

# Ensure git is installed
pacman -Sy --noconfirm archlinux-keyring git

# Clone repo if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    git clone "$REPO_URL"
else
    echo "Repository already exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main
fi

cd "$REPO_DIR"

# Ensure install.sh is executable
chmod +x install.sh

# Run installer
exec ./install.sh
