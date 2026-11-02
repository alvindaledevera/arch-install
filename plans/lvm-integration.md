# Arch Linux LVM Integration Plan

## Overview
This plan details adding optional LVM (Logical Volume Manager) support to the Arch Linux installer script suite. It supports both standalone LVM setups and encrypted LVM (LVM inside LUKS).

---

## 1. Configuration Changes (`vars.conf`)
Add `USE_LVM` option to `vars.conf`:
```bash
USE_LVM="yes"           # use lvm "yes" or "no"
VG_NAME="vg0"           # LVM Volume Group name (default: vg0)
LV_NAME="root"          # LVM Logical Volume name for root (default: root)
```

---

## 2. New Script: `02-disk-setup/02b-lvm.sh`
Insert a new step in `02-disk-setup/` between LUKS setup (`02-luks.sh`) and filesystem creation (`03-filesystem.sh`).

### Execution Flow:
1. **Validation & Configuration**:
   - Check `USE_LVM` variable (defaults to prompting user if unset).
   - Set default `VG_NAME` (`vg0`) and `LV_NAME` (`root`).
2. **Determine Underlying Physical Device**:
   - If `USE_LUKS=="yes"`, use `/dev/mapper/cryptroot`.
   - If `USE_LUKS=="no"`, use `$ROOT_PART`.
3. **LVM Creation**:
   - Clean existing Volume Groups/Physical Volumes on the device if present.
   - Run `pvcreate "$PV_DEV"`
   - Run `vgcreate "$VG_NAME" "$PV_DEV"`
   - Run `lvcreate -l 100%FREE "$VG_NAME" -n "$LV_NAME"`
4. **Environment Export**:
   - Set `TARGET_DEV="/dev/$VG_NAME/$LV_NAME"`
   - Export `TARGET_DEV`, `USE_LVM`, `VG_NAME`, `LV_NAME`.

---

## 3. Updates to Existing Scripts

### `02-disk-setup/03-filesystem.sh`
- Update `TARGET_DEV` selection:
  - If `USE_LVM=="yes"`, `TARGET_DEV="/dev/$VG_NAME/$LV_NAME"`.
  - Else if `USE_LUKS=="yes"`, `TARGET_DEV="/dev/mapper/cryptroot"`.
  - Else, `TARGET_DEV="$ROOT_PART"`.

### `02-disk-setup/04-mount.sh`
- Ensure Volume Group is active (`vgchange -ay "$VG_NAME"` if `USE_LVM=="yes"`).
- Ensure LUKS container is opened if encrypted prior to activating VG.

### `03-installation/01-pacstrap.sh`
- Add `lvm2` to `BASE_PKGS` array so `pvcreate`, `vgcreate`, `lvcreate`, and `lvm` hooks are available in target system.

### `04-configure-system/04-initramfs.sh`
- If `USE_LVM=="yes"`, add `lvm2` hook to `mkinitcpio.conf` `HOOKS` array.
- Order of hooks for systemd initramfs:
  - LUKS + LVM: `... block sd-encrypt lvm2 filesystems ...`
  - LVM only: `... block lvm2 filesystems ...`

---

## 4. Verification Workflow
1. Verify script sequencing in `install.sh` (`run_dir "02-disk-setup"` will execute `01-partition.sh`, `02-luks.sh`, `02b-lvm.sh`, `03-filesystem.sh`, `04-mount.sh` in order).
2. Validate syntax of modified scripts with `bash -n`.

---

## Todo Checklist
- [x] Analyze disk setup scripts for LVM integration
- [x] Design LVM configuration logic and update `vars.conf`
- [x] Create `02-disk-setup/02b-lvm.sh`
- [x] Update `02-disk-setup/03-filesystem.sh`
- [x] Update `02-disk-setup/04-mount.sh`
- [x] Update `03-installation/01-pacstrap.sh` to include `lvm2`
- [x] Update `04-configure-system/04-initramfs.sh` to add `lvm2` hook
