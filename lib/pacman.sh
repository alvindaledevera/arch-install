#!/usr/bin/env bash

pacman_install() {
  pacman --noconfirm --needed -S "$@"
}

pacman_update() {
  pacman --noconfirm -Syu
}

pacstrap_install() {
  pacstrap /mnt "$@"
}

enable_service() {
  systemctl enable "$1"
}
