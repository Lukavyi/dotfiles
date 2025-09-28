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