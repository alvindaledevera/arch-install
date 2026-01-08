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

# -----------------------------
# USER SCRIPTS
# -----------------------------
if id \"$USERNAME\" &>/dev/null; then
    echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    echo '▶ Running USER scripts'
    echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

    for script in /root/arch-install/scripts/user/[0-9][0-9]*.sh; do
        [ -f \"\$script\" ] || continue
        echo \"➡ Running as $USERNAME: \$(basename \"\$script\")\"

        runuser -u \"$USERNAME\" -- bash \"\$script\" \
            |& tee \"/home/$USERNAME/\$(basename \"\$script\").log\"
    done
else
    echo \"⚠ User $USERNAME not found — skipping user scripts\"
fi
"
