#!/usr/bin/env bash
set -e

echo "⏱ Setting hostname, locale, keyboard, and timezone..."

# -------------------------
# Hostname
# -------------------------
echo "$HOSTNAME" > /etc/hostname

# -------------------------
# Localization
# -------------------------
echo "LANG=$LOCALE" > /etc/locale.conf
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen

# -------------------------
# Keyboard
# -------------------------
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# -------------------------
# Timezone & NTP
# -------------------------
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc
timedatectl set-ntp true

echo "✅ System configuration complete"
