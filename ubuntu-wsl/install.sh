#!/bin/bash

set -Eeuo pipefail

source packages.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(basename "$SCRIPT_DIR")" = "ubuntu-wsl" ]; then
  REPO_ROOT="$(dirname "$SCRIPT_DIR")"
else
  REPO_ROOT="$SCRIPT_DIR"
fi

install_cmd() {
  "$SUDO_CMD" apt install -y "$@"
}

install_pkg() {
  echo "Installing packages..."
  install_cmd "${APPS[@]}"

  read -p "Install optional programming packages? [y/N] " programming_choice

  if [[ "$programming_choice" =~ ^[Yy]$ ]]; then
    echo "Installing optional programming packages..."
    install_cmd "${PROGRAMMING_PACKAGES[@]}"

    echo "Installing Bun..."
    (
      install_bun
    )

    echo "Installing GitHub CLI..."
    (
      install_github_cli
    )

    echo "Installing Copilot CLI..."
    (
      install_copilot_cli
    )

    echo "Installing OpenCode..."
    (
      install_opencode
    )
  fi

  echo "Installing Fzf..."
  (
    install_fzf
  )

  echo "Installing Fastfetch..."
  (
    install_fastfetch
  )

  echo "Installing Starship..."
  (
    install_starship
  )
}

setup_config_dir() {
  CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
  mkdir -p "$CONF_DIR"
}

copy_configs() {
  echo "Copying config files..."

  setup_config_dir

  CONFIG_SOURCES=(
    fastfetch
    starship
    tmux
  )

  for src in "${CONFIG_SOURCES[@]}"; do
    SRC_PATH="$REPO_ROOT/$src"
    [ -d "$SRC_PATH" ] || {
      echo "Warning: $src does not exist, skipping..."
      continue
    }

    name=$(basename "$SRC_PATH")
    dest="${CONF_DIR}/${name}"

    [ -e "$dest" ] && mv -v "$dest" "${dest}.bak"
    cp -r "$SRC_PATH" "$dest"
    echo "Copied $SRC_PATH → $dest"
  done
}

copy_home_configs() {
  echo "Copying home config files..."

  HOME_FILES=(
    .vimrc
    .bashrc
    .bash_profile
    .zshrc
  )

  for file in "${HOME_FILES[@]}"; do
    SRC_FILE="$REPO_ROOT/$file"
    [ -f "$SRC_FILE" ] || continue

    dest="$HOME/$file"
    [ -f "$dest" ] && mv -v "$dest" "${dest}.bak"
    cp "$SRC_FILE" "$dest"
    echo "Copied $SRC_FILE → $dest"
  done
}

change_shell() {
  read -p "Change shell to zsh? [y/N] " shell_choice

  if [[ "$shell_choice" =~ ^[Yy]$ ]]; then
    chsh -s "$(command -v zsh)"
  fi
}

install_tmux_tpm() {
  TPM_DIR="$HOME/.config/tmux/plugins/tpm"
  mkdir -p "$(dirname "$TPM_DIR")"

  if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  fi
}

install_pkg
setup_docker
copy_configs
copy_home_configs
change_shell
install_tmux_tpm

echo "Installation finished!"
