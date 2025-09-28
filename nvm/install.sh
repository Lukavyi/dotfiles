#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_nvm_node() {
    print_info "Setting up NVM and Node.js..."
    export NVM_DIR="$HOME/.nvm"

    # Load NVM based on OS
    if [[ "$OS" == "macos" ]]; then
        # macOS - check both Intel and Apple Silicon paths
        if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
            source "/opt/homebrew/opt/nvm/nvm.sh"
        elif [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
            source "/usr/local/opt/nvm/nvm.sh"
        fi
    else
        # Linux
        if [[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ]]; then
            source "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
        fi
    fi

    # Check if NVM is loaded
    if command -v nvm &>/dev/null; then
        echo "Installing latest LTS Node.js via NVM..."
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'
        print_success "Node.js $(node --version) installed and set as default"
        print_success "npm $(npm --version) is now available"
    else
        print_warning "NVM not found. Node.js will need to be installed manually"
        print_warning "Please install NVM via Homebrew first: brew install nvm"
    fi
}

# Main execution
main() {
    install_nvm_node
}

main "$@"