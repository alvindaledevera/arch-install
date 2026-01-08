#!/usr/bin/env bash
set -e

# -----------------------------
# Copy full arch-install folder into chroot
# -----------------------------
cp -r "$ROOT_DIR" /mnt/root/arch-install

arch-chroot /mnt /bin/bash -c "
set -e

# Load UI helpers
source /root/arch-install/scripts/lib/ui.sh

export EFI_PART='$EFI_PART'
export ARCH_PART='$ARCH_PART'
export HOSTNAME='$HOSTNAME'
export USERNAME='$USERNAME'
export KEYMAP='$KEYMAP'
export LOCALE='$LOCALE'
export TIMEZONE='$TIMEZONE'

echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
echo '▶ Running ROOT chroot scripts'
echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

for script in /root/arch-install/scripts/chroot/[0-9][0-9]*.sh; do
    print_stage \"\$script\"
    source \"\$script\"
done


"

# Copy the entire arch-install folder to the user's home
cp -r /root/arch-install /home/$USERNAME/
chown -R $USERNAME:$USERNAME /home/$USERNAME/arch-install
