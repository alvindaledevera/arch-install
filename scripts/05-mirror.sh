#!/usr/bin/env bash
set -e

echo "🌍 Detecting country for fastest mirrors..."

# Detect country via IP (fallback to PH)
COUNTRY="$(curl -fsSL https://ipapi.co/country || true)"
COUNTRY="${COUNTRY}"

echo "📍 Using mirror country: $COUNTRY"

echo "⚡ Installing reflector (if needed)..."
pacman -Sy --noconfirm reflector

echo "🚀 Updating mirrorlist..."
reflector \
  --country "$COUNTRY" \
  --protocol https \
  --latest 10 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist

echo "⚙️ Enabling parallel downloads..."

# Uncomment + set ParallelDownloads safely
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
  sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
  echo 'ParallelDownloads = 5' >> /etc/pacman.conf
fi

echo "✅ Mirrors updated and parallel downloads enabled"
