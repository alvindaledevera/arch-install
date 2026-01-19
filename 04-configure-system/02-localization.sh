#!/usr/bin/env bash
set -euo pipefail

ui_banner "Localization Configuration"

# -------------------------------------------------
# Defaults (used only if not set in vars.conf)
# -------------------------------------------------
# LOCALE_DEFAULT="en_US.UTF-8"
# LANG_DEFAULT="en_US.UTF-8"
# KEYMAP_DEFAULT="us"

# -------------------------------------------------
# Resolve variables (vars.conf → default → prompt)
# -------------------------------------------------

# ----- LOCALE -----
if [[ -z "${LOCALE:-}" ]]; then
    ui_step "Locale not set in vars.conf"
    read -rp "Enter locale [default: $LOCALE_DEFAULT]: " LOCALE
    LOCALE="${LOCALE:-$LOCALE_DEFAULT}"
else
    ui_info "Using locale from vars.conf: $LOCALE"
fi

# ----- LANG -----
if [[ -z "${LANG:-}" ]]; then
    read -rp "Enter language [default: $LANG_DEFAULT]: " LANG
    LANG="${LANG:-$LANG_DEFAULT}"
else
    ui_info "Using language from vars.conf: $LANG"
fi

# ----- KEYMAP -----
if [[ -z "${KEYMAP:-}" ]]; then
    read -rp "Enter keyboard layout [default: $KEYMAP_DEFAULT]: " KEYMAP
    KEYMAP="${KEYMAP:-$KEYMAP_DEFAULT}"
else
    ui_info "Using keyboard layout from vars.conf: $KEYMAP"
fi

ui_info "Final locale   : $LOCALE"
ui_info "Final language : $LANG"
ui_info "Final keymap   : $KEYMAP"

# -------------------------------------------------
# Validate locale exists in locale.gen
# -------------------------------------------------
if ! grep -Eq "^\s*#?\s*$LOCALE" /etc/locale.gen; then
    ui_error "Locale '$LOCALE' not found in /etc/locale.gen"
    ui_info "Hint: run → less /etc/locale.gen"
    exit 1
fi

# -------------------------------------------------
# Enable locale
# -------------------------------------------------
ui_step "Enabling locale $LOCALE"
sed -i "s|^#\s*\($LOCALE\)|\1|" /etc/locale.gen

# -------------------------------------------------
# Generate locales
# -------------------------------------------------
ui_step "Generating locales"
locale-gen

# -------------------------------------------------
# Write locale configuration
# -------------------------------------------------
ui_step "Writing /etc/locale.conf"
cat <<EOF > /etc/locale.conf
LANG=$LANG
EOF

# -------------------------------------------------
# Set console keyboard layout
# -------------------------------------------------
ui_step "Writing /etc/vconsole.conf"
cat <<EOF > /etc/vconsole.conf
KEYMAP=$KEYMAP
EOF

ui_success "Localization configured successfully"
