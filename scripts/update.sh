#!/usr/bin/env bash
# Incremental config update via nixos-rebuild switch.
# Run from anywhere; uses your personal SSH key.

set -euo pipefail

HOST="${HOST:-128.254.224.230}"
SSH_USER="${SSH_USER:-caramel}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "→ nixos-rebuild switch → ${SSH_USER}@${HOST}"
nixos-rebuild switch \
  --flake "${REPO_ROOT}#test-vm" \
  --target-host "${SSH_USER}@${HOST}" \
  --use-remote-sudo
