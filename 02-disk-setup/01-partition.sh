#!/usr/bin/env bash
set -euo pipefail

# ===================================================
# 02-disk-setup/01-partition.sh
# Partition the target disk
# Supports UEFI, GPT, and multiple disks (nvme, ssd, hdd)
# ===================================================

ui_banner "Disk Partitioning"

# Safety check
if [[ -z "${DISK:-}" ]]; then
    ui_error "DISK variable not set! Please set in vars.conf"
    exit 1
fi

if [[ ! -b "$DISK" ]]; then
    ui_error "Disk not found: $DISK"
    exit 1
fi

ui_info "Target disk: $DISK"

# Warn user
ui_warn "THIS WILL ERASE ALL DATA ON $DISK"
if [[ "${AUTO_CONFIRM:-false}" != "true" ]]; then
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || exit 1
fi

# -----------------------------
# Create GPT + EFI + root
# -----------------------------
ui_step "Creating GPT partition table..."
parted "$DISK" --script mklabel gpt

# EFI Partition
ui_step "Creating EFI partition (${EFI_SIZE})..."
parted "$DISK" --script mkpart ESP fat32 1MiB "${EFI_SIZE}"
parted "$DISK" --script set 1 boot on

# Root Partition (rest of disk)
ui_step "Creating root partition..."
parted "$DISK" --script mkpart primary  "${EFI_SIZE}" 100%

# -----------------------------
# Format partitions (placeholder)
# -----------------------------
ui_step "Partitions created successfully:"
lsblk "$DISK" -o NAME,SIZE,FSTYPE,MOUNTPOINT

ui_success "Disk partitioning complete"
