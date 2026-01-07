print_stage() {
  local stage_name
  stage_name=$(basename "$1")
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ Running: $stage_name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo

  # Auto-pause for 1 second
  sleep 1
}
