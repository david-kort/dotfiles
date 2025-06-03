# Dotfiles

A modern, cross-platform dotfiles repository optimized for VS Code devcontainers and development environments.

## Features

- 🍺 **Homebrew-based package management** - Works consistently across macOS and Linux
- ⚡ **Lazygit integration** - Beautiful Git TUI with custom configuration
- 🐳 **Devcontainer ready** - Designed to work seamlessly in VS Code devcontainers
- 🔧 **Modular setup** - Easy to extend with additional tools and configurations

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## What's Installed

### Package Manager
- **Homebrew** - The missing package manager for macOS and Linux

### Development Tools
- **lazygit** - A simple terminal UI for git commands

## Usage in VS Code Devcontainers

Add this to your devcontainer configuration to automatically set up your dotfiles:

```json
{
  "name": "Development Container",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {}
  },
  "postCreateCommand": "curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh | bash",
  "remoteUser": "vscode"
}
```

## Configuration Files

The repository includes optimized configurations for:

- **Lazygit** (`config/lazygit/config.yml`) - Custom key bindings and UI settings

## Extending

To add more tools:

1. Add installation logic to `install.sh` using Homebrew when possible
2. Add configuration files to the `config/` directory
3. Update the `link_configs()` function to symlink your new configs

## Architecture

This dotfiles setup follows modern best practices:

- **Cross-platform compatibility** - Works on macOS, Linux, and in containers
- **Package manager first** - Uses Homebrew for consistent package management
- **Symlinked configs** - Configuration files are symlinked, not copied
- **Idempotent installation** - Safe to run multiple times
- **Shell agnostic** - Works with bash, zsh, and other shells

## Requirements

- `curl` - For downloading Homebrew and other resources
- `git` - For cloning repositories
- `bash` - For running the installation script

All other dependencies are installed automatically via Homebrew.

## License

MIT License - feel free to fork and customize for your own use!