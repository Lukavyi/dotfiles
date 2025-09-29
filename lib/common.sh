#!/bin/bash
# Common utilities and variables for all install scripts

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# Get the dotfiles directory (parent of lib/)
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Simple OS detection
export OS="unknown"
[[ "$OSTYPE" == "darwin"* ]] && export OS="macos"
[[ "$OSTYPE" == "linux-gnu"* ]] && export OS="linux"

# Detect Linux distribution if on Linux
export DISTRO=""
if [[ "$OS" == "linux" ]]; then
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) DISTRO="debian" ;;
            fedora|rhel|centos) DISTRO="redhat" ;;
            arch|manjaro) DISTRO="arch" ;;
            *) DISTRO="unknown" ;;
        esac
    fi
fi

# Disable Homebrew auto-update to prevent unwanted updates
export HOMEBREW_NO_AUTO_UPDATE=1

# Helper functions
print_success() {
    printf "${GREEN}✓ %s${NC}\n" "$1"
}

print_error() {
    printf "${RED}✗ %s${NC}\n" "$1"
}

print_warning() {
    printf "${YELLOW}⚠ %s${NC}\n" "$1"
}

print_info() {
    printf "${BLUE}%s${NC}\n" "$1"
}

# Source Homebrew into current shell environment
source_brew() {
    # Check if brew is already available
    if command -v brew &>/dev/null; then
        return 0
    fi

    # Try to source brew based on OS
    if [[ "$OS" == "macos" ]]; then
        # Try both Apple Silicon and Intel paths
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null && return 0
        fi
        if [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null && return 0
        fi
    elif [[ "$OS" == "linux" ]]; then
        # Linux Homebrew path
        if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null && return 0
        fi
    fi

    return 1
}

# Ensure brew is available, exit if not
ensure_brew() {
    if ! source_brew; then
        print_error "Homebrew is not installed or not found in expected locations"
        print_info "Expected locations:"
        print_info "  macOS: /opt/homebrew/bin/brew or /usr/local/bin/brew"
        print_info "  Linux: /home/linuxbrew/.linuxbrew/bin/brew"
        exit 1
    fi
}