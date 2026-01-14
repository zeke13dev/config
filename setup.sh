#!/bin/bash

# Zeke's Machine Setup Script
# This script installs tools and sets up configs for a new machine

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Config directory (where this script lives)
CONFIG_DIR="$HOME/.config"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is designed for macOS"
    exit 1
fi

echo ""
echo "=========================================="
echo "   Zeke's Machine Setup Script"
echo "=========================================="
echo ""

# ============================================
# HOMEBREW
# ============================================
install_homebrew() {
    log_info "Checking for Homebrew..."
    if command -v brew &> /dev/null; then
        log_success "Homebrew is already installed"
        brew update
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed"
    fi
}

# ============================================
# CLI TOOLS
# ============================================
install_cli_tools() {
    log_info "Installing CLI tools via Homebrew..."

    # Core tools
    BREW_PACKAGES=(
        # Editors
        helix

        # Terminal & Shell
        ghostty
        oh-my-posh
        zsh

        # File management
        yazi

        # Search & navigation
        ripgrep
        fd
        fzf
        eza         # modern ls replacement
        bat         # cat with syntax highlighting
        zoxide      # smarter cd

        # Git tools
        git
        gh          # GitHub CLI
        lazygit     # TUI for git

        # Development utilities
        jq          # JSON processor
        tree
        wget
        curl
        httpie      # HTTP client

        # Build tools
        cmake
        make

        # System monitoring
        btop            # process viewer
        htop

        # Terminal multiplexer
        tmux

        # Git enhancements
        delta           # better diffs

        # Utilities
        tldr            # simplified man pages
        direnv          # per-directory env vars
        fastfetch       # system info
        rclone          # cloud storage sync

        # Database
        postgresql@17
    )

    for pkg in "${BREW_PACKAGES[@]}"; do
        if brew list "$pkg" &> /dev/null; then
            log_success "$pkg is already installed"
        else
            log_info "Installing $pkg..."
            brew install "$pkg" || log_warn "Failed to install $pkg"
        fi
    done
}

# ============================================
# FONTS
# ============================================
install_fonts() {
    log_info "Installing fonts..."

    # Add font cask tap
    brew tap homebrew/cask-fonts 2>/dev/null || true

    FONTS=(
        font-jetbrains-mono-nerd-font
        font-fira-code-nerd-font
        font-hack-nerd-font
    )

    for font in "${FONTS[@]}"; do
        if brew list --cask "$font" &> /dev/null; then
            log_success "$font is already installed"
        else
            log_info "Installing $font..."
            brew install --cask "$font" || log_warn "Failed to install $font"
        fi
    done
}

# ============================================
# LANGUAGE TOOLCHAINS
# ============================================
install_languages() {
    log_info "Installing language toolchains..."

    # Rust
    log_info "Setting up Rust..."
    if command -v rustup &> /dev/null; then
        log_success "Rust is already installed"
        rustup update stable
    else
        log_info "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    # Install rust-analyzer
    rustup component add rust-analyzer 2>/dev/null || true

    # Go
    log_info "Setting up Go..."
    if ! brew list go &> /dev/null; then
        brew install go
    else
        log_success "Go is already installed"
    fi

    # Node.js via nvm
    log_info "Setting up Node.js via nvm..."
    if ! brew list nvm &> /dev/null; then
        brew install nvm
        mkdir -p "$HOME/.nvm"
    else
        log_success "nvm is already installed"
    fi

    # Python tools
    log_info "Setting up Python tools..."
    PYTHON_TOOLS=(
        python3
        pyright     # LSP
        black       # Formatter
        ruff        # Fast linter
    )
    for tool in "${PYTHON_TOOLS[@]}"; do
        if ! brew list "$tool" &> /dev/null; then
            brew install "$tool" || log_warn "Failed to install $tool"
        else
            log_success "$tool is already installed"
        fi
    done

    # OCaml
    log_info "Setting up OCaml..."
    if ! brew list opam &> /dev/null; then
        brew install opam
        opam init -y --disable-sandboxing
    else
        log_success "opam is already installed"
    fi

    # LLVM (for clangd)
    log_info "Setting up LLVM/clangd..."
    if ! brew list llvm &> /dev/null; then
        brew install llvm
    else
        log_success "LLVM is already installed"
    fi

    # LaTeX tools
    log_info "Setting up LaTeX tools..."
    LATEX_TOOLS=(texlab)
    for tool in "${LATEX_TOOLS[@]}"; do
        if ! brew list "$tool" &> /dev/null; then
            brew install "$tool" || log_warn "Failed to install $tool"
        else
            log_success "$tool is already installed"
        fi
    done

    # TypeScript/JavaScript tools (via npm after nvm is set up)
    log_info "TypeScript/JavaScript tools will be installed after shell restart with nvm"
}

# ============================================
# OH MY ZSH
# ============================================
install_oh_my_zsh() {
    log_info "Setting up Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh is already installed"
    else
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# ============================================
# CONFIG FILES
# ============================================
setup_configs() {
    log_info "Setting up config files..."

    # Ensure .config directory exists
    mkdir -p "$HOME/.config"

    # List of config directories to ensure exist
    CONFIG_DIRS=(
        helix
        ghostty
        oh-my-posh
        yazi
        git
    )

    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$SCRIPT_DIR/$dir" ]]; then
            log_success "Config for $dir exists in $SCRIPT_DIR/$dir"
        else
            log_warn "No config found for $dir"
        fi
    done

    # Create yazi config if it doesn't exist
    if [[ ! -d "$CONFIG_DIR/yazi" ]]; then
        log_info "Creating yazi config directory..."
        mkdir -p "$CONFIG_DIR/yazi"

        # Create a basic yazi config
        cat > "$CONFIG_DIR/yazi/yazi.toml" << 'EOF'
[manager]
ratio = [1, 3, 4]
sort_by = "natural"
sort_sensitive = false
sort_reverse = false
sort_dir_first = true
linemode = "size"
show_hidden = false
show_symlink = true

[preview]
tab_size = 2
max_width = 600
max_height = 900
EOF

        cat > "$CONFIG_DIR/yazi/keymap.toml" << 'EOF'
[[manager.prepend_keymap]]
on = ["<Esc>"]
run = "escape"
desc = "Exit visual mode, clear selected, or cancel search"

[[manager.prepend_keymap]]
on = ["q"]
run = "quit"
desc = "Quit"

[[manager.prepend_keymap]]
on = ["<Enter>"]
run = "open"
desc = "Open selected file(s)"
EOF

        cat > "$CONFIG_DIR/yazi/theme.toml" << 'EOF'
# Use the built-in Tokyo Night theme as a base
# You can customize colors here
EOF

        log_success "Created yazi config"
    fi
}

# ============================================
# ZSHRC SETUP
# ============================================
setup_zshrc() {
    log_info "Setting up .zshrc..."

    ZSHRC="$HOME/.zshrc"

    # Backup existing .zshrc if it exists and isn't a symlink
    if [[ -f "$ZSHRC" && ! -L "$ZSHRC" ]]; then
        log_info "Backing up existing .zshrc to .zshrc.backup"
        cp "$ZSHRC" "$HOME/.zshrc.backup"
    fi

    # Create a clean .zshrc
    cat > "$ZSHRC" << 'EOF'
# Zeke's Zsh Configuration
# Generated by setup.sh

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Disable default theme (using oh-my-posh instead)
ZSH_THEME=""

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================
# ENVIRONMENT VARIABLES
# ============================================
export EDITOR=hx
export VISUAL=hx

# ============================================
# PATH CONFIGURATION
# ============================================
# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Cargo/Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$(go env GOPATH 2>/dev/null)/bin"

# LLVM (for clangd)
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# PostgreSQL (adjust version as needed)
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# ============================================
# NVM (Node Version Manager)
# ============================================
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ============================================
# OPAM (OCaml Package Manager)
# ============================================
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>&1

# ============================================
# C++ FLAGS (for macOS SDK)
# ============================================
export CXXFLAGS="-I$(xcrun --show-sdk-path)/usr/include/c++/v1 -stdlib=libc++"
export CPPFLAGS="-I$(xcrun --show-sdk-path)/usr/include/c++/v1"

# ============================================
# OH MY POSH PROMPT
# ============================================
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/zeke-purple.omp.json)"
fi

# ============================================
# ALIASES
# ============================================
# Modern replacements
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias cat='bat'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# Editor
alias e='hx'
alias edit='hx'

# Yazi file manager with cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ============================================
# ZOXIDE (smarter cd)
# ============================================
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# ============================================
# FZF
# ============================================
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# ============================================
# DIRENV
# ============================================
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# ============================================
# LOCAL OVERRIDES
# ============================================
# Source local config if it exists (for machine-specific settings, secrets, etc.)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
EOF

    log_success "Created .zshrc"
    log_info "Put any secrets/tokens in ~/.zshrc.local (this file is sourced at the end)"
}

# ============================================
# ZSH PLUGINS
# ============================================
install_zsh_plugins() {
    log_info "Installing Zsh plugins..."

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        log_success "zsh-autosuggestions is already installed"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        log_success "zsh-syntax-highlighting is already installed"
    fi
}

# ============================================
# POST-INSTALL: NPM PACKAGES
# ============================================
install_npm_packages() {
    log_info "Installing global npm packages..."

    # Check if nvm is available and node is installed
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"

    if command -v nvm &> /dev/null; then
        # Install latest LTS if no node version exists
        if ! command -v node &> /dev/null; then
            log_info "Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
        fi

        NPM_PACKAGES=(
            typescript
            typescript-language-server
            prettier
            @tailwindcss/language-server
            eslint
        )

        for pkg in "${NPM_PACKAGES[@]}"; do
            if npm list -g "$pkg" &> /dev/null; then
                log_success "$pkg is already installed"
            else
                log_info "Installing $pkg..."
                npm install -g "$pkg" || log_warn "Failed to install $pkg"
            fi
        done
    else
        log_warn "nvm not available, skipping npm packages. Run this section again after shell restart."
    fi
}

# ============================================
# GIT CONFIG
# ============================================
setup_git_config() {
    log_info "Setting up git config..."

    # Only set up delta if not already configured
    if ! git config --global core.pager &> /dev/null; then
        git config --global core.pager "delta"
        git config --global interactive.diffFilter "delta --color-only"
        git config --global delta.navigate true
        git config --global delta.dark true
        git config --global delta.line-numbers true
        git config --global merge.conflictstyle "diff3"
        git config --global diff.colorMoved "default"
        log_success "Git delta configured"
    else
        log_success "Git pager already configured"
    fi

    # Set default branch name
    git config --global init.defaultBranch main 2>/dev/null || true
}

# ============================================
# MAIN
# ============================================
main() {
    # Parse arguments
    SKIP_BREW=false
    SKIP_LANGS=false
    SKIP_CONFIG=false
    SKIP_ZSH=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-brew) SKIP_BREW=true; shift ;;
            --skip-langs) SKIP_LANGS=true; shift ;;
            --skip-config) SKIP_CONFIG=true; shift ;;
            --skip-zsh) SKIP_ZSH=true; shift ;;
            --help|-h)
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  --skip-brew    Skip Homebrew and CLI tools installation"
                echo "  --skip-langs   Skip language toolchain installation"
                echo "  --skip-config  Skip config file setup"
                echo "  --skip-zsh     Skip Zsh/Oh-My-Zsh setup"
                echo "  --help, -h     Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Run installation steps
    if [[ "$SKIP_BREW" != true ]]; then
        install_homebrew
        install_cli_tools
        install_fonts
    fi

    if [[ "$SKIP_LANGS" != true ]]; then
        install_languages
    fi

    if [[ "$SKIP_ZSH" != true ]]; then
        install_oh_my_zsh
        install_zsh_plugins
        setup_zshrc
    fi

    if [[ "$SKIP_CONFIG" != true ]]; then
        setup_configs
    fi

    # Try to install npm packages (may need shell restart)
    install_npm_packages

    # Setup git config
    setup_git_config

    echo ""
    echo "=========================================="
    echo "   Setup Complete!"
    echo "=========================================="
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Put any secrets/tokens in ~/.zshrc.local"
    echo "  3. If npm packages failed, run: nvm install --lts && npm install -g typescript typescript-language-server prettier"
    echo ""
    log_success "Enjoy your new setup!"
}

main "$@"
