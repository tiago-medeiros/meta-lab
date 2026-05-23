#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh: Installs prerequisites and initializes the entire lab.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'

log_info()  { echo -e "${COLOR_GREEN}[INFO]${COLOR_RESET} $*"; }
log_warn()  { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $*"; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*"; exit 1; }

# Check required tools
check_deps() {
  local tools=("make" "docker" "kubectl" "terraform" "helm" "kind")
  local missing=()

  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      missing+=("$tool")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    log_error "Missing tools: ${missing[*]}"
  fi

  log_info "All dependencies satisfied."
}

# Create lab namespaces
setup_k8s() {
  local kubeconfig="${LAB_ROOT}/../lab-k8s/kubeconfig"

  if [[ ! -f "$kubeconfig" ]]; then
    log_warn "Kubeconfig not found. Run 'make -C ../lab-k8s setup' first."
    return
  fi

  local namespaces=(infra observability messaging argocd platform-lab)

  for ns in "${namespaces[@]}"; do
    kubectl --kubeconfig "$kubeconfig" create namespace "$ns" --dry-run=client -o yaml | \
      kubectl --kubeconfig "$kubeconfig" apply -f - 2>/dev/null || true
  done

  log_info "Namespaces created."
}

# Initialize terraform
init_terraform() {
  local terraform_dir="${LAB_ROOT}/../lab-infra/terraform"

  if [[ ! -d "$terraform_dir" ]]; then
    log_warn "Terraform dir not found at $terraform_dir"
    return
  fi

  (cd "$terraform_dir" && terraform init)
  log_info "Terraform initialized."
}

main() {
  log_info "=== Platform Engineering Lab Bootstrap ==="

  check_deps
  setup_k8s
  init_terraform

  log_info "=== Bootstrap complete! ==="
  log_info "Run 'make -C ../lab-infra deploy' to provision infra."
  log_info "Run 'make -C ../lab-k8s deploy' to deploy k8s resources."
}

main "$@"
