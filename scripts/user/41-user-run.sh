#!/usr/bin/env bash
set -e

# -----------------------------
# Run all USER scripts
# -----------------------------
if [ -z "$USERNAME" ]; then
    echo "❌ USERNAME variable not set. Exiting."
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▶ Running USER scripts"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Loop through all user scripts
    for script in /home/$USERNAME/user/*.sh; do
        [[ "$script" == *"41-user-run.sh"* ]] && continue  # skip this runner
        source /home/$USERNAME/lib/ui.sh  # ensure print_stage is available
        print_stage "$script"
        bash "$script"
    done
else
    echo "⚠ User $USERNAME not found — skipping user scripts"
fi
