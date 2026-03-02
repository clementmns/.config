# Dotfiles

Minimal macOS terminal configuration.

## Structure

```
.config/
├── zsh/           # Zsh configuration (sources .config/zsh/zshrc)
├── starship/     # Starship prompt config
├── neofetch/     # Neofetch config + custom ASCII
├── ghostty/      # Ghostty terminal config
├── btop/        # Btop config
├── nvim/       # Neovim config
├── zed/        # Zed editor config
├── raycast/    # Raycast config
├── flashspace/ # Flashspace config
├── posting/    # Posting config
└── install.sh # Brew packages installer
```

## Setup

1. Run the installer:
   ```bash
   ./install.sh
   ```

2. Link `~/.zshrc` to `~/.config/zsh/zshrc`:
   ```bash
   echo 'source "$HOME/.config/zsh/zshrc"' > ~/.zshrc
   ```

## Components

- **Shell**: zsh + starship prompt
- **Terminal**: Ghostty
- **Editor**: Neovim, Zed
- **System Info**: neofetch (custom minimal output), btop
