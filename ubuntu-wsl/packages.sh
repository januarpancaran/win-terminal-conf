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
  curl
  git
  htop
  ripgrep
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
  zoxide
  zsh
)

PROGRAMMING_PACKAGES=(
  composer
  dotnet-sdk-10.0
  golang
  jq
  libxml2-utils
  lua5.4
  mysql-server
  openjdk-25-jdk
  php
  postgresql
  python3
  python3-pip
  sqlite3
)

install_fzf() {
  if ! cmd_exists fzf; then
    FZF_DIR="$HOME/.fzf"

    if [ -d "$FZF_DIR" ]; then
      mv -v "$FZF_DIR" "$FZF_DIR".bak
    fi

    git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
    "${FZF_DIR}/install"
  fi
}

install_neovim() {
  if ! cmd_exists nvim; then
    local pkg_name="nvim-linux-x86_64"
    set +e
    curl -LO https://github.com/neovim/neovim/releases/latest/download/${pkg_name}.tar.gz
    set -e

    "$SUDO_CMD" rm -rf "/opt/${pkg_name}"
    "$SUDO_CMD" tar -C /opt -xzf "${pkg_name}.tar.gz"

    rm -f "${pkg_name}.tar.gz"
  fi
}

install_fnm() {
  if ! cmd_exists fnm; then
    set +e
    curl -fsSL https://fnm.vercel.app/install | bash
    set -e

    export FNM_PATH="$HOME/.local/share/fnm"
    if [ ! -x "$FNM_PATH/fnm" ]; then
      FNM_PATH="$HOME/.fnm"
    fi

    if [ ! -x "$FNM_PATH/fnm" ]; then
      return 1
    fi

    export PATH="$FNM_PATH:$PATH"
    eval "$("$FNM_PATH/fnm" env --shell bash)"
    "$FNM_PATH/fnm" install 24
    "$FNM_PATH/fnm" default 24
  fi
}

install_bun() {
  if ! cmd_exists bun; then
    set +e
    curl -fsSL https://bun.sh/install | bash
    set -e
  fi
}

install_fastfetch() {
  if ! cmd_exists fastfetch; then
    local pkg_name="fastfetch-linux-amd64.deb"

    curl -LO https://github.com/fastfetch-cli/fastfetch/releases/latest/download/${pkg_name}

    "$SUDO_CMD" apt install -y "./${pkg_name}"

    rm -f "${pkg_name}"
  fi
}

install_starship() {
  if ! cmd_exists starship; then
    set +e
    curl -sS https://starship.rs/install.sh | sh
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
