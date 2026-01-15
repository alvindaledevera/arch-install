#!/usr/bin/env bash

ui_banner() {
  echo -e "\n\033[1;34m==> $1\033[0m"
}

ui_section() {
  echo -e "\n\033[1;36m-- $1\033[0m"
}

ui_step() {
  echo -e "   • $1"
}

ui_success() {
  echo -e "\033[1;32m[OK]\033[0m $1"
}

ui_warn() {
  echo -e "\033[1;33m[WARN]\033[0m $1"
}

ui_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}
