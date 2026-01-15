#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 02-disk-setup/01-partition.sh
# Manual Disk Partitioning with cfdisk
# Dual-boot safe: select EFI / root partitions
# Optional LUKS encryption
# ===================================================

ui_banner "Disk Partitioning (Manual - cfdisk)"

# -----------------------------
# List all disks
# -----------------------------
ui_step "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk

read -rp "Enter disk to partition manually (e.g. /dev/sda, /dev/nvme0n1): " DISK
[[ -b "$DISK" ]] || { ui_error "Disk not found: $DISK"; exit 1; }

# -----------------------------
# Open cfdisk for manual partitioning
# -----------------------------
ui_info "Opening cfdisk for manual partitioning..."
ui_info "Create EFI (FAT32) and root partitions as needed."
ui_info "Make sure EFI partition has 'boot' flag."
ui_info "After finishing, write changes and quit."

cfdisk "$DISK"

echo
ui_step "After finishing partitioning in cfdisk, enter the partitions to use:"

# -----------------------------
# EFI partition
# -----------------------------
read -rp "EFI partition (FAT32, boot): " EFI_PART
[[ -b "$EFI_PART" ]] || { ui_error "EFI partition not found"; exit 1; }

# -----------------------------
# Root partition
# -----------------------------
read -rp "Root partition (WILL BE FORMATTED): " ROOT_PART
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
