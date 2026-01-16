#!/usr/bin/env bash
set -euo pipefail

ui_banner "Localization Configuration"

# -----------------------------
# Default locale
# -----------------------------
DEFAULT_LOCALE="${DEFAULT_LOCALE:-en_US.UTF-8}"
DEFAULT_LANG="${DEFAULT_LANG:-en_US.UTF-8}"
DEFAULT_KEYMAP="${DEFAULT_KEYMAP:-us}"

ui_info "Default locale: $DEFAULT_LOCALE"
ui_info "Default language: $DEFAULT_LANG"
ui_info "Default keyboard layout: $DEFAULT_KEYMAP"

# -----------------------------
# Locale selection
# -----------------------------
read -rp "Enter locale [default: $DEFAULT_LOCALE]: " LOCALE
LOCALE="${LOCALE:-$DEFAULT_LOCALE}"

read -rp "Enter language [default: $DEFAULT_LANG]: " LANG
LANG="${LANG:-$DEFAULT_LANG}"

read -rp "Enter keyboard layout [default: $DEFAULT_KEYMAP]: " KEYMAP
KEYMAP="${KEYMAP:-$DEFAULT_KEYMAP}"

# -----------------------------
# Enable locale in /etc/locale.gen
# -----------------------------
ui_info "Enabling locale $LOCALE..."
sed -i "s/^#\s*\($LOCALE\)/\1/" /etc/locale.gen

# -----------------------------
# Generate locales
# -----------------------------
ui_info "Generating locales..."
locale-gen

# -----------------------------
# Set system-wide locale
# -----------------------------
ui_info "Setting /etc/locale.conf..."
echo "LANG=$LANG" > /etc/locale.conf

# -----------------------------
# Set keyboard layout
# -----------------------------
ui_info "Setting keyboard layout to $KEYMAP..."
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

ui_success "Localization configured successfully"
