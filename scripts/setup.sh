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

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        info "Docker already installed."
        return 0
    fi
    info "Installing Docker CE and Compose (official repo)..."
    if [ -f /etc/debian_version ]; then
        sudo apt install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        error "Docker install: unsupported OS. Please install manually."
        return 1
    fi
}

install_cockpit() {
    if command -v cockpit >/dev/null 2>&1 || systemctl is-active --quiet cockpit; then
        info "Cockpit already installed."
        return 0
    fi
    info "Installing Cockpit..."
    sudo apt install -y cockpit
    sudo systemctl enable --now cockpit.socket
}

install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        info "Zsh already installed."
        return 0
    fi
    info "Installing Zsh..."
    sudo apt install -y zsh
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || info "Oh My Zsh install script exited (may require user interaction or already installed)"
    info "To set Zsh as your default shell, run: chsh -s $(which zsh)"
}

install_nix() {
    if command -v nix >/dev/null 2>&1; then
        info "Nix already installed."
        return 0
    fi
    info "Installing Nix package manager..."
    # Official multi-user install, non-interactive
    sh <(curl -L https://nixos.org/nix/install) --daemon || {
        error "Nix installation failed. Please check logs or install manually."
        return 1
    }
    info "Nix installation complete. You may need to restart your shell or source /etc/profile.d/nix.sh."
}

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
    install_nix
    install_zsh
    install_cockpit
    install_docker
    setup_volumes_and_dirs
    info "Setup complete. You can now run 'make up' to start services."
}

main "$@"
