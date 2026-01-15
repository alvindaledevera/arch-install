#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# Defaults (safe kahit commented sa vars.conf)
# -------------------------------------------------
AUTO_CONFIRM="${AUTO_CONFIRM:-false}"
FS_TYPE="${FS_TYPE:-btrfs}"
FORCE_DISK_PROMPT="${FORCE_DISK_PROMPT:-true}"

# -------------------------------------------------
# Detect VM
# -------------------------------------------------
VM_DETECTED=false
if grep -qi virtual /sys/class/dmi/id/product_name 2>/dev/null; then
    VM_DETECTED=true
fi

# -------------------------------------------------
# Detect available disks
# -------------------------------------------------
mapfile -t AVAILABLE_DISKS < <(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}')

if [[ ${#AVAILABLE_DISKS[@]} -eq 0 ]]; then
    ui_error "No disks detected"
    exit 1
fi

# -------------------------------------------------
# Disk selection (ALWAYS PROMPT)
# -------------------------------------------------
ui_section "Disk selection"

for i in "${!AVAILABLE_DISKS[@]}"; do
    size=$(lsblk -dn -o SIZE "${AVAILABLE_DISKS[$i]}")
    echo "  [$i] ${AVAILABLE_DISKS[$i]} ($size)"
done

read -rp "Select disk to install on: " disk_idx

if [[ -z "${disk_idx}" || ! "${disk_idx}" =~ ^[0-9]+$ || -z "${AVAILABLE_DISKS[$disk_idx]:-}" ]]; then
    ui_error "Invalid disk selection"
    exit 1
fi

DISK="${AVAILABLE_DISKS[$disk_idx]}"

# -------------------------------------------------
# Partition naming (NVMe vs SATA/VM)
# -------------------------------------------------
if [[ "$DISK" =~ nvme ]]; then
    EFI_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
else
    EFI_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi

# -------------------------------------------------
# VM adjustments
# -------------------------------------------------
if [[ "$VM_DETECTED" == "true" ]]; then
    ui_warn "Virtual machine detected"
    LUKS_ENABLE=false
fi

# -------------------------------------------------
# Final confirmation
# -------------------------------------------------
ui_banner "Pre-installation: Confirmation"

ui_warn "THIS WILL ERASE THE FOLLOWING DISK"
ui_step "Disk       : $DISK"
ui_step "EFI Part   : $EFI_PART"
ui_step "Root Part  : $ROOT_PART"
ui_step "Filesystem : $FS_TYPE"
ui_step "Hostname   : $HOSTNAME"
ui_step "Timezone   : $TIMEZONE"
ui_step "Locale     : $LOCALE"
ui_step "User       : $USERNAME"
ui_step "VM         : $VM_DETECTED"

if [[ "$AUTO_CONFIRM" != "true" ]]; then
    read -rp "Continue installation? [y/N]: " ans
    [[ "$ans" =~ ^[Yy]$ ]] || {
        ui_error "Installation aborted by user"
        exit 1
    }
fi

ui_success "Confirmation accepted"
