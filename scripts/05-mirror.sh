#!/usr/bin/env bash
set -e

echo "⏱ Updating pacman mirrors and enabling parallel downloads..."

# Install reflector if missing
pacman -Sy --noconfirm reflector

# Try to fetch top 10 fastest PH HTTPS mirrors
echo "🌍 Fetching top 10 fastest PH mirrors..."
mapfile -t MIRRORS < <(reflector --country PH --protocol https --latest 10 --sort rate --save /tmp/mirrorlist.tmp && awk '{print $1}' /tmp/mirrorlist.tmp)

# Fallback to global mirrors if no PH mirrors found
if [ ${#MIRRORS[@]} -eq 0 ]; then
    echo "⚠ No PH mirrors found, using global mirrors..."
    mapfile -t MIRRORS < <(reflector --country all --protocol https --latest 10 --sort rate --save /tmp/mirrorlist.tmp && awk '{print $1}' /tmp/mirrorlist.tmp)
fi

# Let user choose mirror
echo "📋 Select a mirror to use:"
PS3="Enter the number of your choice: "
select MIRROR in "${MIRRORS[@]}"; do
    if [[ -n "$MIRROR" ]]; then
        echo "✅ You selected: $MIRROR"
        # Save selected mirror to pacman mirrorlist
        echo "Server = $MIRROR" > /etc/pacman.d/mirrorlist
        break
    else
        echo "❌ Invalid selection, try again."
    fi
done

# Enable parallel downloads safely
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    echo 'ParallelDownloads = 5' >> /etc/pacman.conf
fi

echo "✅ Mirrorlist updated and parallel downloads enabled"
