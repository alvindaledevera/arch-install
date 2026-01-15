#!/usr/bin/env bash
set -euo pipefail

ui_banner "Disk Partitioning (Manual - cfdisk)"

# -------------------------------------------------
# Detect available disks
# -------------------------------------------------
mapfile -t DISKS < <(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}')
[[ ${#DISKS[@]} -gt 0 ]] || { ui_error "No disks detected"; exit 1; }

# -------------------------------------------------
# Disk picker
# -------------------------------------------------
ui_section "Select disk"
for i in "${!DISKS[@]}"; do
    size=$(lsblk -dn -o SIZE "${DISKS[$i]}")
    echo "  [$i] ${DISKS[$i]} ($size)"
done
read -rp "Select disk number: " DISK_IDX
[[ "$DISK_IDX" =~ ^[0-9]+$ ]] && [[ -n "${DISKS[$DISK_IDX]:-}" ]] || { ui_error "Invalid disk selection"; exit 1; }
DISK="${DISKS[$DISK_IDX]}"
ui_info "Using disk: $DISK"

# -------------------------------------------------
# Unmount any mounted partitions and close LUKS
# -------------------------------------------------
ui_info "Unmounting any mounted partitions on $DISK..."
umount -R "$DISK"* 2>/dev/null || true

ui_info "Closing any LUKS containers on $DISK..."
for mapper in $(ls /dev/mapper 2>/dev/null); do
    if cryptsetup status "$mapper" &>/dev/null; then
        ui_info "Closing LUKS container $mapper..."
        cryptsetup close "$mapper" || true
    fi
done

# -------------------------------------------------
# Open cfdisk for manual partitioning
# -------------------------------------------------
ui_info "Opening cfdisk..."
ui_info "Create / reuse EFI (FAT32) + root partitions"
ui_info "DO NOT touch Windows partitions if dual-booting"
cfdisk "$DISK"
sync
sleep 1

# -------------------------------------------------
# Show partitions
# -------------------------------------------------
ui_section "Detected partitions"
lsblk -f "$DISK"
echo

# -------------------------------------------------
# Collect partitions
# -------------------------------------------------
mapfile -t PARTS < <(lsblk -lnpo NAME,FSTYPE "$DISK" | awk '$2 != "loop" {print $1 "|" $2}')
[[ ${#PARTS[@]} -gt 0 ]] || { ui_error "No partitions found"; exit 1; }

# -------------------------------------------------
# EFI partition picker
# -------------------------------------------------
ui_section "Select EFI partition (FAT32)"
EFI_CANDIDATES=()
for p in "${PARTS[@]}"; do
    name="${p%%|*}"; fs="${p##*|}"
    [[ "$fs" == "vfat" ]] && EFI_CANDIDATES+=("$name")
done
[[ ${#EFI_CANDIDATES[@]} -gt 0 ]] || { ui_error "No FAT32 partition found (EFI required)"; exit 1; }

for i in "${!EFI_CANDIDATES[@]}"; do
    size=$(lsblk -dn -o SIZE "${EFI_CANDIDATES[$i]}")
    echo "  [$i] ${EFI_CANDIDATES[$i]} ($size)"
done
read -rp "Select EFI partition: " EFI_IDX
[[ "$EFI_IDX" =~ ^[0-9]+$ ]] && [[ -n "${EFI_CANDIDATES[$EFI_IDX]:-}" ]] || { ui_error "Invalid EFI selection"; exit 1; }
EFI_PART="${EFI_CANDIDATES[$EFI_IDX]}"

# -------------------------------------------------
# ROOT partition picker
# -------------------------------------------------
ui_section "Select ROOT partition (WILL BE FORMATTED)"
ROOT_CANDIDATES=()
for p in "${PARTS[@]}"; do
    name="${p%%|*}"
    [[ "$name" != "$EFI_PART" ]] && ROOT_CANDIDATES+=("$name")
done
for i in "${!ROOT_CANDIDATES[@]}"; do
    size=$(lsblk -dn -o SIZE "${ROOT_CANDIDATES[$i]}")
    fs=$(lsblk -dn -o FSTYPE "${ROOT_CANDIDATES[$i]}")
    echo "  [$i] ${ROOT_CANDIDATES[$i]} ($size, fs=${fs:-none})"
done
read -rp "Select ROOT partition: " ROOT_IDX
[[ "$ROOT_IDX" =~ ^[0-9]+$ ]] && [[ -n "${ROOT_CANDIDATES[$ROOT_IDX]:-}" ]] || { ui_error "Invalid root selection"; exit 1; }
ROOT_PART="${ROOT_CANDIDATES[$ROOT_IDX]}"

# -------------------------------------------------
# Default encryption = YES
# -------------------------------------------------
USE_LUKS="yes"

# -------------------------------------------------
# Summary
# -------------------------------------------------
ui_banner "Partition Summary"
ui_step "Disk       : $DISK"
ui_step "EFI Part   : $EFI_PART"
ui_step "Root Part  : $ROOT_PART"
ui_step "LUKS Root  : $USE_LUKS"

# -------------------------------------------------
# Final confirmation (default YES)
# -------------------------------------------------
read -rp "Continue with this layout? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
[[ "$CONFIRM" =~ ^[Yy]([Ee][Ss])?$ ]] || { ui_error "Aborted by user"; exit 1; }

ui_success "Partition layout confirmed"

# -------------------------------------------------
# Export
# -------------------------------------------------
export DISK EFI_PART ROOT_PART USE_LUKS
