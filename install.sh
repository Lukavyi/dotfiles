#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions for output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo $ID
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Install stow if not available
install_stow() {
    local os="$1"
    
    if ! command -v stow &> /dev/null; then
        print_info "Installing GNU Stow..."
        case $os in
            "macos")
                if command -v brew &> /dev/null; then
                    brew install stow
                else
                    print_error "Homebrew required but not found. Install Homebrew first."
                    exit 1
                fi
                ;;
            "linux")
                if command -v apt-get &> /dev/null; then
                    sudo apt-get update && sudo apt-get install -y stow
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm stow
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y stow
                else
                    print_error "Unsupported package manager. Please install stow manually."
                    exit 1
                fi
                ;;
        esac
        print_success "GNU Stow installed"
    fi
}

# Install Homebrew if not present (cross-platform)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH based on OS
        local os=$(detect_os)
        case $os in
            "macos")
                # Add Homebrew to PATH (works for both Intel and Apple Silicon)
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
                # Try both paths for current session
                eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
                ;;
            "linux")
                # Add Homebrew to PATH for Linux
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                ;;
        esac
        
        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

# Install packages from Brewfile
install_brew_packages() {
    local brewfile_path="brew/Brewfile"
    
    if [[ ! -f "$brewfile_path" ]]; then
        print_warning "Brewfile not found at $brewfile_path, skipping package installation"
        return 1
    fi
    
    if command -v brew &> /dev/null; then
        print_info "Installing Homebrew packages from $brewfile_path..."
        brew bundle --file="$brewfile_path" --no-lock || {
            print_warning "Some packages may have failed to install"
            print_info "This is normal on Linux - casks and Mac App Store apps are macOS-only"
            print_info "Run 'brew bundle check --file=$brewfile_path' to see what's missing"
        }
        print_success "Homebrew packages installation completed"
    else
        print_error "Homebrew not available"
        return 1
    fi
}

# Install global npm packages
install_npm_packages() {
    if [[ -f "npm/package.json" ]]; then
        print_info "Installing global npm packages from package.json..."
        cd npm && npm install -g && cd ..
    else
        print_warning "npm/package.json not found, skipping npm packages"
    fi
}

# Install essential system packages that might not be available via Homebrew (Linux only)
install_system_packages() {
    print_info "Installing essential system packages..."
    
    DISTRO=$(detect_distro)
    
    case $DISTRO in
        "ubuntu"|"debian")
            sudo apt-get update
            # Essential build tools and system packages
            sudo apt-get install -y build-essential curl file git python3-pip
            ;;
        "fedora"|"rhel"|"centos")
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y curl file git python3-pip
            ;;
        "arch"|"manjaro")
            sudo pacman -S --noconfirm base-devel curl file git python-pip
            ;;
        *)
            print_warning "Unsupported distribution for automatic system package installation"
            ;;
    esac
    
    print_success "System packages installation completed"
}

# Check if running in supported directory
check_directory() {
    if [[ ! -f "install.sh" || ! -d "zsh" || ! -d "git" ]]; then
        print_error "Please run this script from the dotfiles directory"
        exit 1
    fi
}


# Main installation logic
main() {
    print_info "🏠 Setting up dotfiles..."
    
    # Check prerequisites
    check_directory
    
    # Detect OS
    OS=$(detect_os)
    print_info "Detected OS: $OS"
    
    if [[ "$OS" == "unknown" ]]; then
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    # Install stow
    install_stow "$OS"
    
    # Install system packages for Linux
    if [[ "$OS" == "linux" ]]; then
        print_info "🐧 Installing Linux system packages..."
        install_system_packages
    fi
    
    # Install Homebrew and packages (cross-platform)
    print_info "📦 Installing Homebrew and packages..."
    install_homebrew
    install_brew_packages
    
    # Platform-specific completion messages
    case $OS in
        "macos")
            print_success "🍎 macOS installation completed!"
            print_info "Note: All packages (CLI tools, GUI apps, Mac App Store apps) installed via Homebrew"
            ;;
        "linux")
            print_success "🐧 Linux installation completed!"
            print_info "Note: CLI tools and development packages installed via Homebrew"
            print_info "GUI applications (casks) and Mac App Store apps are automatically skipped on Linux"
            ;;
    esac
    
    # Install shared configurations
    print_info "📂 Installing shared configurations with stow..."
    
    if [[ -d "zsh" ]]; then
        stow zsh
        print_success "Zsh configuration linked"
    fi
    
    if [[ -d "git" ]]; then
        stow git
        
        # Create platform-specific git config symlink
        if [[ -f "git/.gitconfig.$OS" ]]; then
            ln -sf "$(pwd)/git/.gitconfig.$OS" ~/.gitconfig.platform
            print_success "Git configuration linked (with platform-specific settings)"
        else
            print_success "Git configuration linked"
        fi
    fi
    
    # Install global npm packages
    install_npm_packages
    
    # Install Claude configuration
    if [[ -d "claude" && -f "claude/install.sh" ]]; then
        print_info "🤖 Installing Claude configuration..."
        cd claude && bash install.sh && cd ..
    fi
    
    # Set up machine-specific configurations
    print_info "⚙️ Setting up machine-specific configurations..."
    
    if [[ ! -f ~/.zshrc.local && -f zsh/.zshrc.local.example ]]; then
        print_info "Creating ~/.zshrc.local from example..."
        cp zsh/.zshrc.local.example ~/.zshrc.local
        print_warning "Please edit ~/.zshrc.local to add your machine-specific configurations"
    fi
    
    if [[ ! -f ~/.zprofile.local && -f zsh/.zprofile.local.example ]]; then
        print_info "Creating ~/.zprofile.local from example..."
        cp zsh/.zprofile.local.example ~/.zprofile.local
        print_warning "Please edit ~/.zprofile.local to add your machine-specific login configurations"
    fi
    
    print_success "🎉 Dotfiles installation complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Edit ~/.zshrc.local and ~/.zprofile.local for machine-specific settings"
    echo "  2. Restart your shell or run: source ~/.zshrc"
    if [[ "$OS" == "macos" ]]; then
        echo "  3. Check brew bundle installation with: brew bundle check --file=brew/Brewfile"
    fi
}

# Run main function
main "$@"