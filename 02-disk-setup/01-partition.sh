# -----------------------------
# Show updated partitions after cfdisk
# -----------------------------
echo
ui_info "Syncing disks..."
sleep 1  # Give kernel time to update partition table
lsblk -f "$DISK"
echo