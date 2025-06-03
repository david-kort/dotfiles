.PHONY: install test clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  install  - Install dotfiles and packages"
	@echo "  test     - Test the installation script"
	@echo "  clean    - Remove installed configurations"
	@echo "  help     - Show this help message"

# Install dotfiles
install:
	@./install.sh

# Test installation (dry run would be nice, but for now just check syntax)
test:
	@bash -n install.sh && echo "✅ Install script syntax is valid"
	@if [ -f Brewfile ]; then brew bundle check --file=Brewfile || echo "ℹ️  Some packages in Brewfile are not installed"; fi

# Clean up symlinked configurations
clean:
	@echo "Removing symlinked configurations..."
	@rm -f ~/.config/lazygit/config.yml
	@echo "✅ Cleanup completed"

# Update Homebrew packages
update:
	@if command -v brew >/dev/null 2>&1; then \
		echo "Updating Homebrew packages..."; \
		brew update && brew upgrade; \
		if [ -f Brewfile ]; then brew bundle --file=Brewfile; fi; \
	else \
		echo "Homebrew not installed"; \
	fi
