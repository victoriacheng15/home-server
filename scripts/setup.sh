#!/usr/bin/env bash
set -euo pipefail

# Update and upgrade system packages once at the start
sudo apt update && sudo apt upgrade -y

# Idempotent setup script for host directories, docker volumes, and essential tools.
# Respects environment variables if set; otherwise falls back to sensible defaults.

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

install_azure_cli() {
    if command -v az >/dev/null 2>&1; then
        info "Azure CLI already installed."
        return 0
    fi
    info "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}

install_gh_cli() {
    if command -v gh >/dev/null 2>&1; then
        info "GitHub CLI already installed."
        return 0
    fi
    info "Installing GitHub CLI..."
    type -p curl >/dev/null || sudo apt install -y curl
    sudo apt install -y git
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt install -y gh
}

install_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        info "Terraform already installed."
        return 0
    fi
    info "Installing Terraform..."
    sudo apt install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt install -y terraform
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

setup_volumes_and_dirs() {
    if ! command -v docker >/dev/null 2>&1; then
        error "docker is not installed or not in PATH"
        return 1
    fi

    info "Creating named Docker volumes (if missing)..."
    docker volume create "$JENKINS_VOLUME" >/dev/null 2>&1 || info "Volume $JENKINS_VOLUME exists"
    docker volume create "$GITEA_VOLUME" >/dev/null 2>&1 || info "Volume $GITEA_VOLUME exists"
    docker volume create "$POSTGRES_VOLUME" >/dev/null 2>&1 || info "Volume $POSTGRES_VOLUME exists"
}

main() {
    install_docker
    install_azure_cli
    install_gh_cli
    install_terraform
    install_cockpit
    install_zsh
    setup_volumes_and_dirs
    info "Setup complete. You can now run 'make up' to start services."
}

main "$@"
