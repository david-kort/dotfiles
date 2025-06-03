#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Get Homebrew installation path
get_brew_path() {
    if [[ "$(detect_os)" == "macos" ]]; then
        echo "/opt/homebrew"
    else
        # Check both possible Linux locations
        if [ -d "/home/linuxbrew/.linuxbrew" ]; then
            echo "/home/linuxbrew/.linuxbrew"
        elif [ -d "/linuxbrew/.linuxbrew" ]; then
            echo "/linuxbrew/.linuxbrew"
        else
            # Default to the standard location
            echo "/home/linuxbrew/.linuxbrew"
        fi
    fi
}

# Install Homebrew (works on both Linux and macOS)
install_homebrew() {
    if command -v brew &> /dev/null; then
        success "Homebrew is already installed"
        return 0
    fi
    
    info "Installing Homebrew..."
    
    # Install dependencies for Linux
    if [[ "$(detect_os)" == "debian" ]]; then
        info "Installing Homebrew dependencies..."
        if [ "$EUID" -eq 0 ]; then
            apt-get update
            apt-get install -y build-essential procps curl file git
        else
            sudo apt-get update
            sudo apt-get install -y build-essential procps curl file git
        fi
    fi
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    local brew_path="$(get_brew_path)"
    eval "$($brew_path/bin/brew shellenv)"
    
    # Verify installation
    if command -v brew &> /dev/null; then
        success "Homebrew installed successfully: $(brew --version | head -n1)"
    else
        error "Failed to install Homebrew"
        exit 1
    fi
}

# Install packages using Homebrew
install_packages() {
    info "Installing packages via Homebrew..."
    
    # Ensure Homebrew is installed
    install_homebrew
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Install from Brewfile if it exists, otherwise install lazygit directly
    if [ -f "$script_dir/Brewfile" ]; then
        info "Installing packages from Brewfile..."
        if ! brew bundle --file="$script_dir/Brewfile"; then
            warning "brew bundle failed, falling back to direct installation"
            if ! command -v lazygit &> /dev/null; then
                info "Installing lazygit directly..."
                brew install lazygit
            fi
        fi
    else
        # Fallback: install lazygit directly
        if ! command -v lazygit &> /dev/null; then
            info "Installing lazygit..."
            brew install lazygit
        else
            success "lazygit is already installed"
        fi
    fi
    
    # Verify installation
    if command -v lazygit &> /dev/null; then
        success "lazygit installed successfully: $(lazygit --version)"
        # Create alias for lg
        if [[ "$SHELL" == *"zsh"* ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            shell_config="$HOME/.bashrc"
        fi

        if [[ -n "$shell_config" ]]; then
            if ! grep -q "alias lg=" "$shell_config" 2>/dev/null; then
                echo "alias lg='lazygit'" >> "$shell_config"
                success "Added 'lg' alias for lazygit to $shell_config"
            else
                success "'lg' alias already exists in $shell_config"
            fi
        fi
    else
        error "Failed to install lazygit"
        exit 1
    fi
}

# Setup shell environment for Homebrew
setup_shell_env() {
    info "Setting up shell environment..."
    
    local shell_config=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [[ -n "$shell_config" ]]; then
        # Add Homebrew to PATH in shell config
        local brew_path="$(get_brew_path)"
        local brew_env_line="eval \"\$($brew_path/bin/brew shellenv)\""
        
        if ! grep -q "brew shellenv" "$shell_config" 2>/dev/null; then
            echo "" >> "$shell_config"
            echo "# Homebrew" >> "$shell_config"
            echo "$brew_env_line" >> "$shell_config"
            success "Added Homebrew to $shell_config"
        else
            success "Homebrew already configured in $shell_config"
        fi
    fi
}

# Create config directories
create_config_dirs() {
    info "Creating config directories..."
    mkdir -p "$HOME/.config"
    success "Config directories created"
}

# Link configuration files
link_configs() {
    info "Linking configuration files..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Link lazygit config if it exists
    if [ -f "$script_dir/config/lazygit/config.yml" ]; then
        mkdir -p "$HOME/.config/lazygit"
        ln -sf "$script_dir/config/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
        success "Linked lazygit config"
    fi
    
    # Add more config linking here as you expand your dotfiles
}

# Main installation function
main() {
    info "Starting dotfiles installation..."
    info "OS detected: $(detect_os)"
    
    create_config_dirs
    install_packages
    link_configs
    setup_shell_env
    
    success "Dotfiles installation completed!"
    info "Please restart your shell or run: source ~/.zshrc"
}

# Run main function
main "$@"
