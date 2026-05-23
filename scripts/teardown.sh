#!/usr/bin/env bash
set -euo pipefail

# teardown.sh: Destroys all lab resources.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'

log_info() { echo -e "${COLOR_YELLOW}[TEARDOWN]${COLOR_RESET} $*"; }

teardown_domain() {
  local domain="$1"
  local domain_path="${LAB_ROOT}/../$domain"

  if [[ ! -d "$domain_path" ]]; then
    log_info "$domain not found, skipping."
    return
  fi

  log_info "Tearing down $domain..."
  (cd "$domain_path" && make teardown 2>/dev/null) || true
}

main() {
  log_info "=== Platform Engineering Lab Teardown ==="

  teardown_domain "lab-infra"
  teardown_domain "lab-k8s"
  teardown_domain "lab-observability"
  teardown_domain "lab-messaging"
  teardown_domain "lab-gitops"

  log_info "=== Teardown complete! ==="
}

main "$@"
