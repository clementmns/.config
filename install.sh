#!/bin/bash

set -e

echo "Installing Homebrew packages..."

brew install btop
brew install posting
brew install neofetch
brew install flashspace
brew install ghostty
brew install raycast
brew install starship
brew install loop

# CLI tools
brew install colima
brew install eza
brew install fzf
brew install zoxide
brew install tree
brew install tmux

echo "All packages installed successfully!"

# Copy configuration files
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
