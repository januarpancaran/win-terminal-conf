#!/bin/bash

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$*"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$*"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$*" >&2
}

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_SRC="$SCRIPT_DIR"

enable_nonfree() {
    log_info "Enabling non-free repositories..."
    
    sudo sed -i 's/^deb \(.*\) main$/deb \1 main contrib non-free non-free-firmware/' /etc/apt/sources.list
    sudo sed -i 's/^deb-src \(.*\) main$/deb-src \1 main contrib non-free non-free-firmware/' /etc/apt/sources.list

    sudo apt update || log_error "Failed to update package lists"
}

# Array of packages to install
packages=(
    apt-transport-https
    bat
    build-essential
    ca-certificates
    composer
    curl
    fastfetch
    fzf
    gcc
    git
    gnupg-agent
    golang
    htop
    lsb-release
    neovim
    nodejs
    npm
    php
    pyenv
    python3
    ripgrep
    starship
    tmux
    trash-cli
    tree
    unrar
    unzip
    wget
    zip
    zoxide
    zsh
)

install_packages() {
    log_info "Updating and upgrading packages..."
    sudo apt update && sudo apt upgrade -y
    
    log_info "Installing packages..."
    sudo apt install -y "${packages[@]}" || log_error "Failed to install packages"
}

setup_docker() {
    log_info "Setting up Docker..."
    
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    log_info "Installing Docker packages..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

setup_tpm() {
    log_info "Setting up Tmux Plugin Manager..."
    
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
        mkdir -p "$(dirname "$tpm_dir")"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || log_error "Failed to clone TPM"
    else
        log_warn "TPM already installed at $tpm_dir"
    fi
}

setup_bun() {
    if command -v bun &> /dev/null; then
        log_warn "Bun is already installed"
        return 0
    fi
    log_info "Setting up Bun..."
    curl -fsSL https://bun.com/install | bash || log_error "Failed to install Bun"
}

copy_config_files() {
    log_info "Copying configuration files..."
    
    local conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    
    # Create config directory if it doesn't exist
    mkdir -p "$conf_dir"
    
    for item in "$CONF_SRC"/*; do
        if [ ! -e "$item" ]; then
            continue
        fi
        
        local name
        name=$(basename "$item")
        
        # Skip install script and .zshrc
        if [[ "$name" == "install.sh" || "$name" == ".zshrc" ]]; then
            continue
        fi
        
        local target_dir="$conf_dir/$name"
        
        # Special handling for tmux to preserve plugins
        if [ "$name" = "tmux" ]; then
            log_info "Updating tmux config..."
            mkdir -p "$target_dir"
            cp -r "$item"/* "$target_dir/"
            continue
        fi
        
        # Backup existing config
        if [ -d "$target_dir" ]; then
            log_warn "Backing up existing config: $name -> $name.bak"
            rm -rf "${target_dir}.bak"
            mv -v "$target_dir" "$target_dir.bak"
        fi
        
        cp -r "$item" "$conf_dir"
    done
}

setup_shell() {
    printf "Change shell to zsh? [y/N] "
    read -r shell_choice
    
    if [[ "$shell_choice" =~ ^[Yy]$ ]]; then
        if [ -f "$CONF_SRC/.zshrc" ]; then
            log_info "Copying .zshrc to home directory..."
            cp "$CONF_SRC/.zshrc" "$HOME" || log_error "Failed to copy .zshrc"
        else
            log_warn ".zshrc not found in $CONF_SRC, skipping"
            return 0
        fi
        
        log_info "Changing default shell to zsh..."
        chsh -s "$(which zsh)" || log_error "Failed to change shell"
    fi
}

# Main execution
main() {
    log_info "Starting system setup..."
    
    enable_nonfree || return 1
    install_packages || return 1
    setup_docker || return 1
    setup_bun || return 1
    copy_config_files || return 1
    setup_tpm || return 1
    setup_shell || return 1
    
    log_info "Setup completed successfully!"
}

main "$@"