#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

# Get profile from environment or default to work
# Profiles: work, personal (auto-detects OS)
PROFILE="${PROFILE:-work}"

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

        # Source brew for current session (shell profiles are managed by dotfiles)
        source_brew
        print_success "Homebrew installed"
    else
        print_success "Homebrew already installed"
    fi
}

install_brew_packages() {
    # Ensure brew is available before attempting to use it
    ensure_brew

    # Only update if explicitly requested
    if [[ "${FORCE_BREW_UPDATE:-}" == "1" ]]; then
        echo "Updating Homebrew formulae..."
        brew update || print_warning "Some issues occurred during brew update"
        print_success "Homebrew updated"

        echo "Upgrading Homebrew packages..."
        brew upgrade || print_warning "Some packages may have failed to upgrade"
        print_success "Homebrew packages upgraded"
    fi

    # Helper function to install a Brewfile
    install_brewfile() {
        local brewfile="$1"
        local description="$2"

        if [[ -f "$DOTFILES_DIR/brew/$brewfile" ]]; then
            if ! brew bundle --file="$DOTFILES_DIR/brew/$brewfile"; then
                print_error "Failed to install $description packages from $brewfile"
                print_warning "You may need to run this script again or manually install packages"
                return 1
            fi
        else
            print_error "$brewfile not found"
            exit 1
        fi
    }

    # Install packages based on profile
    echo "Installing Homebrew packages ($PROFILE profile)..."

    # All profiles get basic packages
    install_brewfile "Brewfile.basic" "basic"

    # Install Linux-specific packages on Linux (all profiles)
    if [[ "$OS" == "linux" ]]; then
        install_brewfile "Brewfile.linux" "Linux-specific"
    fi

    # Personal profiles get additional packages
    case "$PROFILE" in
        work)
            print_success "Work profile packages installed"
            ;;
        personal)
            install_brewfile "Brewfile.personal" "personal"
            if [[ "$OS" == "macos" ]]; then
                install_brewfile "Brewfile.macos" "macOS"
                print_success "Personal macOS profile packages installed"
            else
                print_success "Personal Linux profile packages installed"
            fi
            ;;
        *)
            print_error "Unknown profile: $PROFILE"
            echo "Valid profiles: work, personal"
            exit 1
            ;;
    esac
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