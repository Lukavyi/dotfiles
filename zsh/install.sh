#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing Oh My Zsh..."
        KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"

        # Remove Oh My Zsh's default .zshrc so stow can link our version
        if [[ -f "$HOME/.zshrc" ]]; then
            rm "$HOME/.zshrc"
            print_info "Removed Oh My Zsh default .zshrc (will be replaced by dotfiles version)"
        fi
    else
        print_success "Oh My Zsh already installed"
    fi
}

install_zsh_plugins() {
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        echo "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        print_success "zsh-syntax-highlighting already installed"
    fi

    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        echo "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        print_success "zsh-autosuggestions already installed"
    fi
}

create_local_config() {
    if [[ ! -f ~/.zshrc.local ]]; then
        echo "# Machine-specific Zsh configuration" > ~/.zshrc.local
        print_warning "Created ~/.zshrc.local for machine-specific settings"
    else
        print_success "~/.zshrc.local already exists"
    fi

    if [[ ! -f ~/.zprofile.local ]]; then
        echo "# Machine-specific login shell environment variables" > ~/.zprofile.local
        print_warning "Created ~/.zprofile.local for machine-specific login settings"
    else
        print_success "~/.zprofile.local already exists"
    fi

    if [[ ! -f ~/.zshenv.local ]]; then
        echo "# Machine-specific environment variables for all shells" > ~/.zshenv.local
        print_warning "Created ~/.zshenv.local for machine-specific environment settings"
    else
        print_success "~/.zshenv.local already exists"
    fi
}

# Main execution
main() {
    print_info "Setting up Zsh with Oh My Zsh..."
    install_oh_my_zsh
    install_zsh_plugins
    create_local_config
    print_success "Zsh setup complete"
}

main "$@"