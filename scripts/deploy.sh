#!/usr/bin/env bash
# Initial deploy to the test VM via nixos-anywhere.
# Run from the test repo root (the test/ directory).
#
# Prerequisites:
#   - Run scripts/bootstrap-sops.sh first
#   - nixos-anywhere in PATH  (nix develop .# from repo root)
#   - SSH root access to the test VM (rescue system)

set -euo pipefail

# ── Preflight: required tools ────────────────────────────────────────────────
MISSING=()
for cmd in nix nixos-anywhere; do
  command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done
if (( ${#MISSING[@]} > 0 )); then
  echo "ERROR: Missing required tools: ${MISSING[*]}"
  echo "  Enter the ops shell:  nix develop .#   (from repo root)"
  exit 1
fi

HOST="${HOST:-2602:fbec:224:0:be24:11ff:fe0d:d151}"
SSH_USER="${SSH_USER:-root}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FLAKE_REF="${FLAKE_REF:-${REPO_ROOT}#test-vm}"
EXTRA_FILES="${REPO_ROOT}/secrets/extra-files"

echo "=== test-vm: NixOS initial deployment ==="
echo "Target:      ${SSH_USER}@[${HOST}]"
echo "Flake:       ${FLAKE_REF}"
echo ""

# ── Pre-flight checks ────────────────────────────────────────────────────────
if [[ ! -f "${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key" ]]; then
  echo "ERROR: Host SSH key missing. Run test/scripts/bootstrap-sops.sh first."
  exit 1
fi

if [[ ! -f "${TEST_DIR}/secrets/secrets.yaml" ]]; then
  echo "ERROR: secrets.yaml missing. Run test/scripts/bootstrap-sops.sh first."
  exit 1
fi

echo "WARNING: This will ERASE all data on /dev/sda at [${HOST}]."
read -rp "Type 'yes' to continue: " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { echo "Aborted."; exit 1; }

# ── Evaluate the flake first ─────────────────────────────────────────────────
echo ""
echo "→ Evaluating flake (dry-run build)..."
nix build "${REPO_ROOT}#nixosConfigurations.test-vm.config.system.build.toplevel" \
  --no-link \
  --show-trace

# ── Deploy ───────────────────────────────────────────────────────────────────
echo ""
echo "→ Running nixos-anywhere..."
nixos-anywhere \
  --flake "${FLAKE_REF}" \
  --extra-files "${EXTRA_FILES}" \
  --ssh-option "StrictHostKeyChecking=accept-new" \
  "${SSH_USER}@[${HOST}]"

echo ""
echo "=== Deployment complete ==="
echo ""
echo "Wait ~1 min for reboot, then:"
echo ""
echo "  SSH in:"
echo "    ssh caramel@[${HOST}]"
echo ""
echo "  Verify Caddy:"
echo "    curl -6 http://[${HOST}]/"
echo "    # Expected: 'it worked'"
echo ""
echo "  Verify Tailscale:"
echo "    ssh caramel@[${HOST}] 'tailscale status'"
echo ""
echo "  Verify sops-nix decrypted the secret:"
echo "    ssh caramel@[${HOST}] 'sudo ls -la /run/secrets/'"
