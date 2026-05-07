#!/bin/bash

set -Eeuo pipefail

SUDO_CMD=""

cmd_exists() {
  command -v "$1" > /dev/null 2>&1
}

if cmd_exists doas; then
  SUDO_CMD="doas"
else
  SUDO_CMD="sudo"
fi

APPS=(
  bat
  build-essential
  curl
  fastfetch
  fzf
  git
  gpg
  htop
  ripgrep
  starship
  tar
  tmux
  trash-cli
  tree
  unrar
  unzip
  vim
  wget
  wl-clipboard
  zip
  zlib1g-dev
  zoxide
  zsh
)

PROGRAMMING_PACKAGES=(
  composer
  dotnet10
  golang
  jq
  libxml2-utils
  libgmp-dev
  libssl-dev
  libyaml-dev
  lua5.5
  liblua5.5-dev
  mysql-server
  nodejs
  npm
  openjdk-25-jdk
  php
  postgresql
  python3
  python3-pip
  python3-venv
  ruby-full
  rustc
  sqlite3
)

install_neovim() {
  if ! cmd_exists nvim; then
    "$SUDO_CMD" add-apt-repository ppa:neovim-ppa/unstable
    "$SUDO_CMD" apt update
    "$SUDO_CMD" apt install -y neovim
  fi
}

setup_npm() {
  local npm_prefix="$HOME/.local/npm-global"

  if ! cmd_exists npm; then
    echo "npm not found, skipping npm setup"
    return 0
  fi

  mkdir -p "$npm_prefix"
  npm config set prefix "$npm_prefix"

  echo "Configured npm global prefix at $npm_prefix"
}

install_bun() {
  if ! cmd_exists bun; then
    set +e
    curl -fsSL https://bun.sh/install | bash
    set -e
  fi
}

install_github_cli() {
  if ! cmd_exists gh; then
    local latest_ver

    latest_ver=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep tag_name | cut -d '"' -f4 | sed 's/v//')

    local pkg_name="gh_${latest_ver}_linux_amd64.deb"

    curl -LO https://github.com/cli/cli/releases/download/v${latest_ver}/${pkg_name}

    "$SUDO_CMD" apt install -y "./${pkg_name}"

    rm -f "${pkg_name}"
  fi
}

install_copilot_cli() {
  if ! cmd_exists copilot; then
    set +e
    curl -fsSL https://gh.io/copilot-install | bash
    set -e
  fi
}

install_opencode() {
  if ! cmd_exists opencode; then
    set +e
    curl -fsSL https://opencode.ai/install | bash
    set -e
  fi
}

setup_docker() {
  "$SUDO_CMD" apt install -y \
    docker.io \
    docker-buildx \
    docker-compose-v2

  "$SUDO_CMD" systemctl enable --now docker

  "$SUDO_CMD" usermod -aG docker "$(whoami)"
}
