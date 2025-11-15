#!/usr/bin/env bash
set -euo pipefail

# Update and upgrade system packages once at the start
sudo apt update && sudo apt upgrade -y

JENKINS_VOLUME=jenkins_data
GITEA_VOLUME=gitea_data
POSTGRES_VOLUME=postgres_data
N8N_VOLUME=n8n_data
JUPYTER_VOLUME=jupyter_data

info()    { echo "[setup] $*"; }
error()   { echo "[setup] ERROR: $*" >&2; }

setup_volumes_and_dirs() {
    if ! command -v docker >/dev/null 2>&1; then
        error "docker is not installed or not in PATH"
        return 1
    fi

    info "Creating named Docker volumes (if missing)..."
    docker volume create "$JENKINS_VOLUME" >/dev/null 2>&1 || info "Volume $JENKINS_VOLUME exists"
    docker volume create "$GITEA_VOLUME" >/dev/null 2>&1 || info "Volume $GITEA_VOLUME exists"
    docker volume create "$POSTGRES_VOLUME" >/dev/null 2>&1 || info "Volume $POSTGRES_VOLUME exists"
    docker volume create "$N8N_VOLUME" >/dev/null 2>&1 || info "Volume $N8N_VOLUME exists"
    docker volume create "$JUPYTER_VOLUME" >/dev/null 2>&1 || info "Volume $JUPYTER_VOLUME exists"
}


# Azure CLI, GitHub CLI, and Terraform are now provided by the Nix environment.
main() {
    setup_volumes_and_dirs
    info "Setup complete. You can now run 'make up' to start services."
}

main "$@"
