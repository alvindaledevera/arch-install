#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 02-disk-setup/01-partition.sh
# Disk selection + manual partitioning (cfdisk)
# ===================================================

ui_banner "Disk Partitioning (Manual - cfdisk)"

# -------------------------------------------------
# Detect available disks
# -------------------------------------------------
mapfile -t AVAILABLE_DISKS < <(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}')

if [[ ${#AVAILABLE_DISKS[@]} -eq 0 ]]; then
    ui_error "No disks detected"
    exit 1
fi

# -------------------------------------------------
# Disk selection
# -------------------------------------------------
ui_section "Disk selection"

for i in "${!AVAILABLE_DISKS[@]}"; do
    size=$(lsblk -dn -o SIZE "${AVAILABLE_DISKS[$i]}")
    echo "  [$i] ${AVAILABLE_DISKS[$i]} ($size)"
done

read -rp "Select disk to partition: " disk_idx

if [[ -z "$disk_idx" || ! "$disk_idx" =~ ^[0-9]+$ || -z "${AVAILABLE_DISKS[$disk_idx]:-}" ]]; then
    ui_error "Invalid disk selection"
    exit 1
fi

DISK="${AVAILABLE_DISKS[$disk_idx]}"
ui_info "Selected disk: $DISK"

# -------------------------------------------------
# Open cfdisk
# -------------------------------------------------
ui_info "Opening cfdisk for manual partitioning..."
ui_info "Create EFI (FAT32) and root partitions as needed."
ui_info "Do NOT touch Windows partitions if dual-booting."
ui_info "Write changes and quit when done."

cfdisk "$DISK"

# -------------------------------------------------
# Show updated partition table
# -------------------------------------------------
echo
ui_info "Refreshing partition table..."
sleep 1
lsblk -f "$DISK"
echo

# -------------------------------------------------
# Select EFI + root partitions
# -------------------------------------------------
read -rp "Enter EFI partition (FAT32, boot): " EFI_PART
[[ -b "$EFI_PART" ]] || { ui_error "EFI partition not found"; exit 1; }

read -rp "Enter root partition (WILL BE FORMATTED): " ROOT_PART
[[ -b "$ROOT_PART" ]] || { ui_error "Root partition not found"; exit 1; }

# -------------------------------------------------
# Optional LUKS
# -------------------------------------------------
read -rp "Encrypt root partition with LUKS? [y/N]: " USE_LUKS
USE_LUKS="${USE_LUKS:-N}"

# -------------------------------------------------
# Summary
# -------------------------------------------------
ui_banner "Partition Summary"
ui_step "Disk        : $DISK"
ui_step "EFI Part    : $EFI_PART"
ui_step "Root Part   : $ROOT_PART"
ui_step "Encrypt root: $USE_LUKS"

# -------------------------------------------------
# Final confirmation
# -------------------------------------------------
if [[ "${AUTO_CONFIRM:-false}" != "true" ]]; then
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || {
        ui_error "Partitioning aborted"
        exit 1
    }
fi

ui_success "Disk and partitions confirmed"

# -------------------------------------------------
# Export for next steps
# -------------------------------------------------
export DISK EFI_PART ROOT_PART USE_LUKS
