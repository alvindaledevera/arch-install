print_stage() {
  local stage_name
  stage_name=$(basename "$1")
  printf "\n╔══════════════════════════════════╗\n"
  printf "▶ Running: %s\n" "$stage_name"
  printf "╚══════════════════════════════════╝\n\n"
}
