#!/usr/bin/env bash
set -e

echo "🌍 Detecting nearest mirrors using GeoIP..."

# Install reflector if missing
pacman -Sy --noconfirm reflector

# Attempt to update mirrorlist using GeoIP (auto-detect country)
if reflector --latest 20 --protocol https --sort rate --geoip --save /etc/pacman.d/mirrorlist; then
    # Try to get detected country from reflector output
    COUNTRY=$(reflector --latest 1 --protocol https --sort rate --geoip | grep 'Mirror' | head -n1 | awk '{print $4}')
    echo "📍 Using mirror country: ${COUNTRY:-Unknown}"
else
    echo "⚠ Failed to detect nearest mirrors, falling back to global mirrors..."
    reflector --latest 20 --protocol https --sort rate --country all --save /etc/pacman.d/mirrorlist
    echo "🌐 Using global mirrors as fallback."
fi

# Enable parallel downloads safely
echo "⚙️ Enabling parallel downloads..."
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
  sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
  echo 'ParallelDownloads = 5' >> /etc/pacman.conf
fi

echo "✅ Mirrors updated and parallel downloads enabled"
