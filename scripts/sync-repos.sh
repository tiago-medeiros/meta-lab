#!/usr/bin/env bash
set -euo pipefail

# sync-repos.sh: Ensures all lab repositories are up to date.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'

log_info() { echo -e "${COLOR_GREEN}[SYNC]${COLOR_RESET} $*"; }
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*"; }

sync_repo() {
  local repo_path="$1"
  local repo_name
  repo_name="$(basename "$repo_path")"

  if [[ ! -d "$repo_path/.git" ]]; then
    log_warn "$repo_name is not a git repo, skipping."
    return
  fi

  (
    cd "$repo_path"
    if git rev-parse --abbrev-ref HEAD 2>/dev/null | grep -q main; then
      git pull --ff-only 2>/dev/null || true
    else
      log_warn "$repo_name is on $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown branch'), skipping."
    fi
  )
}

main() {
  local repos=(
    "${LAB_ROOT}/../lab-infra"
    "${LAB_ROOT}/../lab-k8s"
    "${LAB_ROOT}/../lab-observability"
    "${LAB_ROOT}/../lab-messaging"
    "${LAB_ROOT}/../lab-gitops"
  )

  for repo in "${repos[@]}"; do
    sync_repo "$repo"
  done
}

main "$@"
