#!/usr/bin/env bash

disk_exists() {
  [[ -b "$1" ]]
}

is_mounted() {
  mountpoint -q "$1"
}

mount_if_needed() {
  local dev="$1"
  local mp="$2"

  mkdir -p "$mp"

  if ! is_mounted "$mp"; then
    mount "$dev" "$mp"
  fi
}

luks_is_open() {
  cryptsetup status "$1" &>/dev/null
}

open_luks() {
  local dev="$1"
  local name="$2"

  if ! luks_is_open "$name"; then
    cryptsetup open "$dev" "$name"
  fi
}
