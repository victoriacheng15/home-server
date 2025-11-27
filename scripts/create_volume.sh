#!/usr/bin/env bash
set -euo pipefail

# --- LOAD VOLUMES FROM SHARED LIST ---
VOLUMES_FILE="./volumes.list"

info()  { echo "[volume] $*"; }
error() { echo "[volume] ERROR: $*" >&2; exit 1; }

# Validate volumes.list exists and is readable
if [[ ! -f "$VOLUMES_FILE" ]]; then
  echo "[volume] ERROR: $VOLUMES_FILE not found. Run this script from your project root." >&2
  exit 1
fi

# Load non-empty, non-comment lines
mapfile -t VOLUMES < <(grep -v '^[[:space:]]*#' "$VOLUMES_FILE" | grep -v '^$')
if [[ ${#VOLUMES[@]} -eq 0 ]]; then
  echo "[volume] ERROR: No volumes found in $VOLUMES_FILE" >&2
  exit 1
fi

setup_volumes_and_dirs() {
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is not installed or not in PATH"
    fi

    info "Creating named Docker volumes (if missing)..."
    for vol in "${VOLUMES[@]}"; do
        # Trim whitespace/newlines (in case of Windows line endings or extra spaces)
        vol="${vol//[$'\r\n ']}"
        if [[ -z "$vol" ]]; then
            continue
        fi

        if docker volume inspect "$vol" &>/dev/null; then
            info "Volume '$vol' already exists"
        else
            docker volume create "$vol" &>/dev/null
            info "Created volume '$vol'"
        fi
    done
}

main() {
    setup_volumes_and_dirs
    info "Volumes setup complete."
}

main "$@"