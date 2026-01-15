#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 02-disk-setup/01-partition.sh
# Interactive Disk Partitioning
# Dual-boot safe: reuse EFI or create new
# Optional LUKS encryption
# ===================================================

ui_banner "Disk Partitioning (Manual)"

# -----------------------------
# List all disks
# -----------------------------
ui_step "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk

read -rp "Enter disk to use (e.g. /dev/nvme0n1 or /dev/sda): " DISK
[[ -b "$DISK" ]] || { ui_error "Disk not found: $DISK"; exit 1; }

# -----------------------------
# List partitions on selected disk
# -----------------------------
ui_step "Available partitions on $DISK:"
lsblk "$DISK" -o NAME,SIZE,FSTYPE,MOUNTPOINT

# -----------------------------
# EFI Partition Selection
# -----------------------------
# Detect existing EFI partitions (FAT32, empty mountpoint)
mapfile -t EFI_CANDIDATES < <(lsblk "$DISK" -o NAME,FSTYPE,MOUNTPOINT | awk '$2=="vfat" && $3=="" {print "/dev/"$1}')

if [ ${#EFI_CANDIDATES[@]} -gt 0 ]; then
    ui_step "Existing EFI partitions found:"
    for i in "${!EFI_CANDIDATES[@]}"; do
        echo "  [$i] ${EFI_CANDIDATES[$i]}"
    done
    read -rp "Select EFI partition to use (leave empty to create new if free space exists): " EFI_IDX
    if [[ -n "$EFI_IDX" && "$EFI_IDX" =~ ^[0-9]+$ && "$EFI_IDX" -lt "${#EFI_CANDIDATES[@]}" ]]; then
        EFI_PART="${EFI_CANDIDATES[$EFI_IDX]}"
        ui_info "Using existing EFI: $EFI_PART"
    fi
fi

# If no EFI selected yet, try to create new
if [[ -z "${EFI_PART:-}" ]]; then
    # Detect first free space
    FREE_START=$(parted "$DISK" print free | awk '/Free Space/ {print $2}' | head -n 1)
    if [[ -z "$FREE_START" ]]; then
        ui_error "No free space available to create EFI partition! Please select an existing one."
        exit 1
    fi

    read -rp "Enter size for new EFI partition [1G]: " EFI_SIZE
    EFI_SIZE="${EFI_SIZE:-1G}"

    ui_step "Creating EFI partition..."
    parted "$DISK" --script mkpart ESP fat32 "$FREE_START" "$EFI_SIZE"
    parted "$DISK" --script set 1 boot on
    EFI_PART="${DISK}1"
    ui_info "Created EFI partition: $EFI_PART"
fi

# -----------------------------
# Root Partition Selection
# -----------------------------
read -rp "Enter root partition to install Arch (WILL BE FORMATTED): " ROOT_PART
[[ -b "$ROOT_PART" ]] || { ui_error "Root partition not found"; exit 1; }

# -----------------------------
# Optional LUKS Encryption
# -----------------------------
read -rp "Encrypt root partition with LUKS? [y/N]: " USE_LUKS
USE_LUKS="${USE_LUKS:-N}"

# -----------------------------
# Summary
# -----------------------------
ui_banner "Summary of selections"
ui_step "Disk        : $DISK"
ui_step "EFI Part    : $EFI_PART"
ui_step "Root Part   : $ROOT_PART"
ui_step "Encrypt root: $USE_LUKS"

# -----------------------------
# Final Confirmation
# -----------------------------
if [[ "${AUTO_CONFIRM:-false}" != "true" ]]; then
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || { ui_error "Partitioning aborted"; exit 1; }
fi

ui_success "Partition selection confirmed"

# Export variables for next steps
export DISK EFI_PART ROOT_PART USE_LUKS
