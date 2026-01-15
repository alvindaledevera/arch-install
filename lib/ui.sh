#!/usr/bin/env bash

# -------------------------------------------------
# Colors
# -------------------------------------------------
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
GRAY="\033[0;37m"
RESET="\033[0m"
BOLD="\033[1m"

# -------------------------------------------------
# Internal helpers
# -------------------------------------------------
_ui_line() {
  local char="${1:-═}"
  local width="${2:-50}"
  printf "%*s\n" "$width" "" | tr ' ' "$char"
}

_ui_box() {
  local title="$1"
  local width=50
  local pad=$(( (width - ${#title} - 2) / 2 ))

  echo
  printf "╔"; _ui_line "═" "$width"; printf "╗\n"
  printf "║%*s%s%*s║\n" "$pad" "" "$title" "$pad" ""
  printf "╚"; _ui_line "═" "$width"; printf "╝\n"
}

# -------------------------------------------------
# Public UI functions
# -------------------------------------------------

ui_banner() {
  local title="$1"
  local width=46

  echo
  echo -e "${CYAN}${BOLD}"
  _ui_line "█" "$width"
  printf "█  %-42s█\n" "$title"
  _ui_line "█" "$width"
  echo -e "${RESET}"
}

ui_section() {
  local title="$1"
  _ui_box "$title"
}

ui_step() {
  echo -e "${BLUE}${BOLD}▶${RESET} $1"
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
