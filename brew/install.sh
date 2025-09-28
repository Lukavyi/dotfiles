#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_system_packages() {
    # Install essential system packages on Linux (required for Homebrew)
    if [[ "$OS" == "linux" ]] && [[ -n "$DISTRO" ]]; then
        print_info "Installing essential system packages..."
        case "$DISTRO" in
            debian)
                sudo apt-get update
                sudo apt-get install -y build-essential curl file git python3-pip
                ;;
            redhat)
                sudo dnf groupinstall -y "Development Tools"
                sudo dnf install -y curl file git python3-pip
                ;;
            arch)
                sudo pacman -S --noconfirm base-devel curl file git python-pip
                ;;
            *)
                print_warning "Unknown Linux distribution. You may need to install build tools manually."
                ;;
        esac
        print_success "System packages installed"
    fi
}

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH based on OS
        if [[ "$OS" == "macos" ]]; then
            # Add to shell profiles for persistence
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
            # Try both Intel and Apple Silicon paths for current session
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        else
            # Add to shell profiles for persistence on Linux
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
            # For current session
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null
        fi
        print_success "Homebrew installed and added to PATH"
    else
        print_success "Homebrew already installed"
    fi
}

install_brew_packages() {
    # Only update if explicitly requested
    if [[ "${FORCE_BREW_UPDATE:-}" == "1" ]]; then
        echo "Updating Homebrew formulae..."
        brew update || print_warning "Some issues occurred during brew update"
        print_success "Homebrew updated"

        echo "Upgrading Homebrew packages..."
        brew upgrade || print_warning "Some packages may have failed to upgrade"
        print_success "Homebrew packages upgraded"
    fi

    # Install packages from appropriate Brewfile based on OS
    if [[ "$OS" == "macos" ]] && [[ -f "$DOTFILES_DIR/brew/Brewfile.macos" ]]; then
        echo "Installing Homebrew packages for macOS..."
        brew bundle --file="$DOTFILES_DIR/brew/Brewfile.macos" || {
            print_warning "Some packages may have failed to install"
        }
        print_success "Homebrew packages installed"
    elif [[ "$OS" == "linux" ]] && [[ -f "$DOTFILES_DIR/brew/Brewfile.cli" ]]; then
        echo "Installing Homebrew packages for Linux/CLI..."
        brew bundle --file="$DOTFILES_DIR/brew/Brewfile.cli" || {
            print_warning "Some packages may have failed to install"
        }
        print_success "Homebrew packages installed"
    else
        print_error "No appropriate Brewfile found for $OS"
        echo "  Expected: brew/Brewfile.macos (macOS) or brew/Brewfile.cli (Linux)"
        exit 1
    fi
}

# Main execution
main() {
    print_info "Setting up Homebrew..."
    install_system_packages
    install_homebrew
    install_brew_packages
    print_success "Homebrew setup complete"
}

main "$@"