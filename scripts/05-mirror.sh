#!/usr/bin/env bash
set -e

echo "🌍 Detecting country for fastest mirrors..."

# Try to detect country via IP, fallback to PH
COUNTRY="$(curl -fsSL https://ipapi.co/country || echo PH)"
echo "📍 Using mirror country: $COUNTRY"

echo "⚡ Installing reflector (if needed)..."
pacman -Sy --noconfirm reflector

echo "🚀 Updating mirrorlist..."
# Try updating mirrors for detected country, fallback to global if empty
if ! reflector --country "$COUNTRY" --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist; then
    echo "⚠ No mirrors found for $COUNTRY, using global mirrors..."
    reflector --country all --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
fi

echo "⚙️ Enabling parallel downloads..."
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    echo 'ParallelDownloads = 5' >> /etc/pacman.conf
fi

echo "✅ Mirrors updated and parallel downloads enabled"
