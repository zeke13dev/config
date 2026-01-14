#!/bin/bash

# Zeke's Ubuntu/Debian Setup Script
# This script installs tools and sets up configs for a new Ubuntu machine

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

# Check if running on Linux
if [[ "$(uname)" != "Linux" ]]; then
    log_error "This script is designed for Linux (Ubuntu/Debian)"
    exit 1
fi

# Check for apt
if ! command -v apt &> /dev/null; then
    log_error "apt not found. This script requires Ubuntu/Debian."
    exit 1
fi

echo ""
echo "=========================================="
echo "   Zeke's Ubuntu Setup Script"
echo "=========================================="
echo ""

# ============================================
# SYSTEM UPDATE
# ============================================
update_system() {
    log_info "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    log_success "System updated"
}

# ============================================
# ESSENTIAL BUILD TOOLS
# ============================================
install_build_essentials() {
    log_info "Installing build essentials..."
    sudo apt install -y \
        build-essential \
        curl \
        wget \
        git \
        pkg-config \
        libssl-dev \
        libfontconfig1-dev \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    log_success "Build essentials installed"
}

# ============================================
# CLI TOOLS
# ============================================
install_cli_tools() {
    log_info "Installing CLI tools via apt..."

    APT_PACKAGES=(
        # Shell
        zsh

        # Search & navigation
        ripgrep
        fd-find
        fzf

        # Git tools
        git
        gh

        # Development utilities
        jq
        tree
        httpie
        cmake
        make
        clang
        clangd

        # System monitoring
        btop
        htop

        # Terminal multiplexer
        tmux

        # Utilities
        tldr
        direnv
        neofetch
        rclone

        # Database
        postgresql
        postgresql-contrib

        # Python
        python3
        python3-pip
        python3-venv
    )

    for pkg in "${APT_PACKAGES[@]}"; do
        if dpkg -l "$pkg" &> /dev/null; then
            log_success "$pkg is already installed"
        else
            log_info "Installing $pkg..."
            sudo apt install -y "$pkg" || log_warn "Failed to install $pkg"
        fi
    done

    # Install modern tools not in default repos
    install_modern_cli_tools
}

# ============================================
# MODERN CLI TOOLS (from other sources)
# ============================================
install_modern_cli_tools() {
    log_info "Installing modern CLI tools..."

    # eza (modern ls) - install from cargo later or from GitHub releases
    if ! command -v eza &> /dev/null; then
        log_info "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza || log_warn "Failed to install eza"
    else
        log_success "eza is already installed"
    fi

    # bat (better cat)
    if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
        log_info "Installing bat..."
        sudo apt install -y bat || log_warn "Failed to install bat"
        # Create symlink if installed as batcat
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            mkdir -p ~/.local/bin
            ln -sf $(which batcat) ~/.local/bin/bat
        fi
    else
        log_success "bat is already installed"
    fi

    # zoxide (smarter cd)
    if ! command -v zoxide &> /dev/null; then
        log_info "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        log_success "zoxide is already installed"
    fi

    # delta (better git diffs)
    if ! command -v delta &> /dev/null; then
        log_info "Installing delta..."
        DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
        wget -q "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -O /tmp/delta.deb
        sudo dpkg -i /tmp/delta.deb || sudo apt install -f -y
        rm /tmp/delta.deb
    else
        log_success "delta is already installed"
    fi

    # lazygit
    if ! command -v lazygit &> /dev/null; then
        log_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit.tar.gz /tmp/lazygit
    else
        log_success "lazygit is already installed"
    fi

    # oh-my-posh
    if ! command -v oh-my-posh &> /dev/null; then
        log_info "Installing oh-my-posh..."
        curl -s https://ohmyposh.dev/install.sh | bash -s
    else
        log_success "oh-my-posh is already installed"
    fi
}

# ============================================
# HELIX EDITOR
# ============================================
install_helix() {
    log_info "Installing Helix editor..."

    if command -v hx &> /dev/null; then
        log_success "Helix is already installed"
        return
    fi

    # Add Helix PPA
    sudo add-apt-repository -y ppa:maveonair/helix-editor
    sudo apt update
    sudo apt install -y helix

    log_success "Helix installed"
}

# ============================================
# YAZI FILE MANAGER
# ============================================
install_yazi() {
    log_info "Installing Yazi file manager..."

    if command -v yazi &> /dev/null; then
        log_success "Yazi is already installed"
        return
    fi

    # Yazi needs to be installed from cargo or prebuilt binary
    # Using prebuilt binary
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    wget -q "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip" -O /tmp/yazi.zip
    unzip -q /tmp/yazi.zip -d /tmp/yazi
    sudo mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
    sudo mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/
    rm -rf /tmp/yazi.zip /tmp/yazi

    log_success "Yazi installed"
}

# ============================================
# GHOSTTY TERMINAL
# ============================================
install_ghostty() {
    log_info "Installing Ghostty terminal..."

    if command -v ghostty &> /dev/null; then
        log_success "Ghostty is already installed"
        return
    fi

    # Ghostty needs to be built from source on Linux
    # Check if zig is available
    if ! command -v zig &> /dev/null; then
        log_info "Installing Zig (required to build Ghostty)..."
        # Install zig
        ZIG_VERSION="0.13.0"
        wget -q "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz" -O /tmp/zig.tar.xz
        sudo tar xf /tmp/zig.tar.xz -C /opt
        sudo ln -sf /opt/zig-linux-x86_64-${ZIG_VERSION}/zig /usr/local/bin/zig
        rm /tmp/zig.tar.xz
    fi

    log_warn "Ghostty needs to be built from source."
    log_warn "Clone https://github.com/ghostty-org/ghostty and run 'zig build -Doptimize=ReleaseFast'"
    log_warn "Or check if a package is available for your distro."
    log_info "Alternative: You can use another terminal like Alacritty or Kitty"

    # Offer to install Alacritty as alternative
    read -p "Install Alacritty as an alternative terminal? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt install -y alacritty || log_warn "Alacritty not in repos, try: sudo snap install alacritty --classic"
    fi
}

# ============================================
# FONTS
# ============================================
install_fonts() {
    log_info "Installing Nerd Fonts..."

    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    FONTS=(
        "JetBrainsMono"
        "FiraCode"
        "Hack"
    )

    for font in "${FONTS[@]}"; do
        if ls "$FONT_DIR"/*"${font}"* &> /dev/null; then
            log_success "$font Nerd Font is already installed"
        else
            log_info "Installing $font Nerd Font..."
            wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" -O "/tmp/${font}.zip"
            unzip -q "/tmp/${font}.zip" -d "$FONT_DIR/${font}"
            rm "/tmp/${font}.zip"
        fi
    done

    # Refresh font cache
    fc-cache -fv > /dev/null 2>&1

    log_success "Fonts installed"
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
    if command -v go &> /dev/null; then
        log_success "Go is already installed"
    else
        log_info "Installing Go..."
        GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
        wget -q "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
    fi

    # Node.js via nvm
    log_info "Setting up Node.js via nvm..."
    if [[ -d "$HOME/.nvm" ]]; then
        log_success "nvm is already installed"
    else
        log_info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi

    # Python tools via pip
    log_info "Setting up Python tools..."
    pip3 install --user --upgrade pyright black ruff || log_warn "Failed to install some Python tools"

    # OCaml
    log_info "Setting up OCaml..."
    if command -v opam &> /dev/null; then
        log_success "opam is already installed"
    else
        log_info "Installing opam..."
        sudo apt install -y opam
        opam init -y --disable-sandboxing
    fi

    # LaTeX tools
    log_info "Setting up LaTeX tools..."
    if command -v texlab &> /dev/null; then
        log_success "texlab is already installed"
    else
        # Install via cargo
        if command -v cargo &> /dev/null; then
            cargo install texlab
        else
            log_warn "Cargo not available, skipping texlab"
        fi
    fi
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

    # Set zsh as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Setting zsh as default shell..."
        chsh -s $(which zsh)
    fi
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
# Zeke's Zsh Configuration (Ubuntu)
# Generated by setup-ubuntu.sh

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
# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Cargo/Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="/usr/local/go/bin:$PATH"
export PATH="$PATH:$(go env GOPATH 2>/dev/null)/bin"

# ============================================
# NVM (Node Version Manager)
# ============================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# ============================================
# OPAM (OCaml Package Manager)
# ============================================
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2>&1

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

# Handle Ubuntu's fd-find naming
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    alias fd='fdfind'
fi

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
    source <(fzf --zsh) 2>/dev/null || true
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
# POST-INSTALL: NPM PACKAGES
# ============================================
install_npm_packages() {
    log_info "Installing global npm packages..."

    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

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
# MAIN
# ============================================
main() {
    # Parse arguments
    SKIP_APT=false
    SKIP_LANGS=false
    SKIP_CONFIG=false
    SKIP_ZSH=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-apt) SKIP_APT=true; shift ;;
            --skip-langs) SKIP_LANGS=true; shift ;;
            --skip-config) SKIP_CONFIG=true; shift ;;
            --skip-zsh) SKIP_ZSH=true; shift ;;
            --help|-h)
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  --skip-apt     Skip apt and CLI tools installation"
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
    if [[ "$SKIP_APT" != true ]]; then
        update_system
        install_build_essentials
        install_cli_tools
        install_helix
        install_yazi
        install_ghostty
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
    echo "  1. Log out and back in (or run: exec zsh)"
    echo "  2. Put any secrets/tokens in ~/.zshrc.local"
    echo "  3. If npm packages failed, run: nvm install --lts && npm install -g typescript typescript-language-server prettier"
    echo ""
    log_warn "Note: Ghostty may need manual installation - see https://github.com/ghostty-org/ghostty"
    echo ""
    log_success "Enjoy your new setup!"
}

main "$@"
