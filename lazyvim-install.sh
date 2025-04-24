#!/usr/bin/env bash

set -e

# Detect home and user dynamically
USER_HOME="$HOME"
NVIM_CONFIG="$USER_HOME/.config/nvim"
LAZYVIM_REPO="https://github.com/LazyVim/starter"

# Check and install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "[INFO] Homebrew not found. Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

# Install Neovim via Brew
if ! brew list neovim &>/dev/null; then
  echo "[INFO] Installing Neovim via Homebrew..."
  brew install neovim
fi

# Clean up broken squashfs nvim remnants
if [[ -d "$USER_HOME/squashfs-root" ]]; then
  echo "[INFO] Removing squashfs-root..."
  rm -rf "$USER_HOME/squashfs-root"
fi

if [[ -f "$USER_HOME/.local/bin/nvim" ]]; then
  echo "[INFO] Removing old local nvim binary..."
  rm -f "$USER_HOME/.local/bin/nvim"
fi

# Remove VIMRUNTIME from .zshrc or .bashrc
sed -i '/VIMRUNTIME/d' "$USER_HOME/.zshrc" 2>/dev/null || true
sed -i '/VIMRUNTIME/d' "$USER_HOME/.bashrc" 2>/dev/null || true

unset VIMRUNTIME

# Backup existing config
if [[ -d "$NVIM_CONFIG" ]]; then
  echo "[INFO] Backing up existing Neovim config..."
  mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup.$(date +%s)"
fi

# Clone LazyVim starter
echo "[INFO] Installing LazyVim..."
git clone "$LAZYVIM_REPO" "$NVIM_CONFIG"
rm -rf "$NVIM_CONFIG/.git"

# Launch Neovim once to install plugins
nvim --headless "+Lazy sync" +qa

echo "[SUCCESS] LazyVim installation complete. Launch with: nvim"
