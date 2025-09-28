#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_p10k() {
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        echo "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        print_success "Powerlevel10k theme installed"
    else
        print_success "Powerlevel10k theme already installed"
    fi
}

# Main execution
main() {
    print_info "Setting up Powerlevel10k theme..."

    # Check if Oh My Zsh is installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_error "Oh My Zsh is not installed. Please install it first."
        exit 1
    fi

    install_p10k
    print_success "Powerlevel10k setup complete"
}

main "$@"