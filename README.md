# Zeke's Dotfiles

My personal configuration files and setup scripts for macOS and Ubuntu.

## Quick Install

### macOS

```bash
# Clone to ~/.config
git clone https://github.com/zeke13dev/config.git ~/.config

# Run setup
~/.config/setup.sh
```

### Ubuntu/Debian

```bash
# Clone to ~/.config
git clone https://github.com/zeke13dev/config.git ~/.config

# Run setup
~/.config/setup-ubuntu.sh
```

## What Gets Installed

### CLI Tools
- **helix** - Modal text editor
- **yazi** - Terminal file manager
- **ghostty** - GPU-accelerated terminal (macOS) / Alacritty (Ubuntu)
- **oh-my-posh** - Prompt theme engine
- **ripgrep**, **fd**, **fzf** - Fast search tools
- **eza**, **bat**, **zoxide** - Modern ls/cat/cd replacements
- **lazygit**, **delta** - Git TUI and better diffs
- **tmux**, **btop**, **tldr**, **direnv**

### Language Toolchains
- **Rust** via rustup + rust-analyzer
- **Go**
- **Node.js** via nvm + TypeScript tools
- **Python** + pyright, black, ruff
- **OCaml** via opam
- **LLVM/clangd** for C++
- **texlab** for LaTeX

### Shell
- **Zsh** with Oh My Zsh
- **zsh-autosuggestions** and **zsh-syntax-highlighting**
- Custom prompt via oh-my-posh

## Config Structure

```
~/.config/
├── setup.sh           # macOS setup script
├── setup-ubuntu.sh    # Ubuntu setup script
├── helix/             # Helix editor config
├── ghostty/           # Ghostty terminal config
├── oh-my-posh/        # Prompt theme
├── yazi/              # File manager config
├── git/               # Git config (global ignore)
└── nvim/              # Neovim config (optional)
```

## Options

Skip specific sections:

```bash
# macOS
./setup.sh --skip-brew      # Skip Homebrew/tools
./setup.sh --skip-langs     # Skip language toolchains
./setup.sh --skip-zsh       # Skip Zsh/Oh-My-Zsh
./setup.sh --skip-config    # Skip config setup

# Ubuntu
./setup-ubuntu.sh --skip-apt
./setup-ubuntu.sh --skip-langs
./setup-ubuntu.sh --skip-zsh
./setup-ubuntu.sh --skip-config
```

## Post-Install

1. Restart your terminal or run `source ~/.zshrc`
2. Add secrets/tokens to `~/.zshrc.local` (sourced automatically, not tracked by git)
3. If npm packages failed: `nvm install --lts && npm install -g typescript typescript-language-server prettier`

## Updating

Pull latest and re-run:

```bash
cd ~/.config && git pull
./setup.sh  # or ./setup-ubuntu.sh
```
