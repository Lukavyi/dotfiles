#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_bun() {
    print_info "Installing Bun (JavaScript runtime and toolkit)..."

    # Check if Bun is already installed
    if command -v bun &>/dev/null; then
        local current_version
        current_version=$(bun --version 2>/dev/null || echo "unknown")
        print_info "Bun is already installed (version: $current_version)"
        print_info "Running installer to upgrade to latest version..."
    fi

    # Run official Bun installer
    if curl -fsSL https://bun.sh/install | bash; then
        # Source the shell config to get bun in PATH for this session
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"

        # Verify installation
        if command -v bun &>/dev/null; then
            local installed_version
            installed_version=$(bun --version)
            print_success "Bun v$installed_version installed successfully!"
            print_info "Bun is installed at: $BUN_INSTALL/bin/bun"
            print_info "The PATH will be updated in your shell config (.zshrc/.bashrc)"
        else
            print_warning "Bun was installed but not found in PATH"
            print_info "You may need to restart your shell or run: source ~/.zshrc"
        fi
    else
        print_error "Failed to install Bun"
        exit 1
    fi
}

# Main execution
main() {
    install_bun
}

main "$@"