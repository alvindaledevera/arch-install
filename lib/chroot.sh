#!/usr/bin/env bash

CHROOT_DIR="/mnt"

run_in_chroot() {
  arch-chroot "$CHROOT_DIR" "$@"
}

run_chroot_script() {
  local script="$1"

  if [[ ! -f "$script" ]]; then
    echo "Chroot script not found: $script"
    exit 1
  fi

  arch-chroot "$CHROOT_DIR" /bin/bash < "$script"
}
