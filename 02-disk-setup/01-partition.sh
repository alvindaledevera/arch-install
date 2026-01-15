#!/usr/bin/env bash
set -euo pipefail

ui_banner "Disk Partitioning (Manual)"

# List disks
ui_step "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk

read -rp "Enter disk to use (e.g. /dev/nvme0n1 or /dev/sda): " DISK
[[ -b "$DISK" ]] || { ui_error "Disk not found"; exit 1; }

# List partitions
ui_step "Available partitions on $DISK:"
lsblk "$DISK" -o NAME,SIZE,FSTYPE,MOUNTPOINT

read -rp "Enter EFI partition to use (leave empty to create new): " EFI_PART
if [[ -z "$EFI_PART" ]]; then
    read -rp "Enter size for new EFI partition [1G]: " EFI_SIZE
    EFI_SIZE="${EFI_SIZE:-1G}"
    ui_step "Creating EFI partition..."
    parted "$DISK" --script mkpart ESP fat32 1MiB "$EFI_SIZE"
    parted "$DISK" --script set 1 boot on
    EFI_PART="${DISK}1"
fi

read -rp "Enter root partition to install Arch (will be formatted!): " ROOT_PART
[[ -b "$ROOT_PART" ]] || { ui_error "Root partition not found"; exit 1; }

# Ask about LUKS
read -rp "Encrypt root partition with LUKS? [y/N]: " USE_LUKS
USE_LUKS=${USE_LUKS:-N}

# Summary
ui_banner "Summary of selections"
ui_step "Disk       : $DISK"
ui_step "EFI Part   : $EFI_PART"
ui_step "Root Part  : $ROOT_PART"
ui_step "Encrypt root: $USE_LUKS"

if [[ "${AUTO_CONFIRM:-false}" != "true" ]]; then
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || exit 1
fi

ui_success "Partition selection confirmed"
