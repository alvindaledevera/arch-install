#!/usr/bin/env bash

# -------------------------------------------------
# Colors (safe for TTY)
# -------------------------------------------------
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"

# -------------------------------------------------
# Helpers
# -------------------------------------------------
ui_line() {
  printf '%*s\n' "${1:-60}" '' | tr ' ' '='
}

# -------------------------------------------------
# UI functions
# -------------------------------------------------
ui_banner() {
  echo
  ui_line
  echo -e "${BOLD}$1${RESET}"
  ui_line
  echo
}

ui_section() {
  echo
  echo -e "${BOLD}==> $1${RESET}"
}

ui_step() {
  echo -e "  ${BLUE}->${RESET} $1"
}

ui_info() {
  echo -e "${CYAN}[INFO]${RESET} $1"
}

ui_warn() {
  echo -e "${YELLOW}[WARN]${RESET} $1"
}

ui_error() {
  echo -e "${RED}[ERROR]${RESET} $1"
}

ui_success() {
  echo -e "${GREEN}[OK]${RESET} $1"
}
