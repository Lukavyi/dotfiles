#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_tmux_tpm() {
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        print_success "TPM installed"

        # Install tmux plugins automatically
        echo "Installing tmux plugins..."
        if "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null; then
            print_success "Tmux plugins installed"
        else
            print_warning "Tmux plugins installation may have failed. Run prefix+I in tmux to install manually."
        fi
    else
        # Update existing plugins
        echo "Updating tmux plugins..."
        if "$HOME/.tmux/plugins/tpm/bin/update_plugins" all 2>/dev/null; then
            print_success "Tmux plugins updated"
        else
            print_success "TPM already installed"
        fi
    fi
}

# Main execution
main() {
    print_info "Setting up Tmux Plugin Manager..."

    # Ensure Homebrew is available (tmux is installed via brew)
    ensure_brew

    # Check if tmux is installed
    if ! command -v tmux &>/dev/null; then
        print_warning "Tmux is not installed. Please install it first."
    fi

    install_tmux_tpm
    print_success "Tmux setup complete"
}

main "$@"