#!/bin/bash

set -Eeuo pipefail

SUDO_CMD=""

if command -v doas > /dev/null 2>&1; then
  SUDO_CMD="doas"
else
  SUDO_CMD="sudo"
fi

APPS=(
  bat
  curl
  git
  htop
  ripgrep
  tmux
  trash-cli
  tree
  unrar
  unzip
  vim
  wget
  wl-clipboard
  zip
  zoxide
  zsh
)

PROGRAMMING_PACKAGES=(
  composer
  dotnet-sdk-10.0
  golang
  jq
  lua5.4
  nodejs
  openjdk-25-jdk
  php
  python3
  python3-pip
)

install_fzf() {
  FZF_DIR="$HOME/.fzf"

  if [ -d "$FZF_DIR" ]; then
    mv -v "$FZF_DIR" "$FZF_DIR".bak
  fi

  git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
  "${FZF_DIR}/install"
}

install_bun() {
  curl -fsSL https://bun.sh/install | bash
}

install_fastfetch() {
  local pkg_name="fastfetch-linux-amd64.deb"

  curl -LO https://github.com/fastfetch-cli/fastfetch/releases/latest/download/${pkg_name}

  "$SUDO_CMD" apt install -y "./${pkg_name}"

  rm -f "${pkg_name}"
}

install_starship() {
  curl -sS https://starship.rs/install.sh | sh
}

install_github_cli() {
  local latest_ver

  latest_ver=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')

  local pkg_name="gh_${latest_ver}_linux_amd64.deb"

  curl -LO https://github.com/cli/cli/releases/download/v${latest_ver}/${pkg_name}

  "$SUDO_CMD" apt install -y "./${pkg_name}"

  rm -f "${pkg_name}"
}

install_copilot_cli() {
  curl -fsSL https://gh.io/copilot-install | bash
}

install_opencode() {
  curl -fsSL https://opencode.ai/install | bash
}

setup_docker() {
  "$SUDO_CMD" apt install -y \
    docker.io \
    docker-buildx \
    docker-compose-v2

  "$SUDO_CMD" systemctl enable --now docker

  "$SUDO_CMD" usermod -aG docker "$(whoami)"
}
