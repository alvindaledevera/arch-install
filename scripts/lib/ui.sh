#!/usr/bin/env bash

print_stage() {
  local script_name
  script_name="$(basename "$1")"

  echo
  echo "========================================"
  echo ">>> RUNNING: $script_name"
  echo "========================================"
  echo
}