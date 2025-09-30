#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_go_tools() {
    print_info "Installing Go-based tools..."

    # Ensure Homebrew is available (Go is installed via brew)
    ensure_brew

    # Check if Go is available
    if ! command -v go &>/dev/null; then
        print_error "Go is not installed. Please install Go first (it's in Brewfile.basic)"
        print_warning "Run: brew install go"
        exit 1
    fi

    # Ensure GOPATH is set
    if [[ -z "$GOPATH" ]]; then
        export GOPATH="$HOME/go"
        print_info "GOPATH not set, using default: $GOPATH"
    fi

    # Ensure GOPATH/bin is in PATH
    if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
        export PATH="$GOPATH/bin:$PATH"
        print_info "Added $GOPATH/bin to PATH for this session"
    fi

    # Install lazynpm
    print_info "Installing lazynpm via go install..."
    if go install github.com/jesseduffield/lazynpm@latest; then
        print_success "lazynpm installed successfully!"
        print_info "Make sure $GOPATH/bin is in your PATH"
        print_info "The 'lnpm' alias in .zshrc will use this installation"
    else
        print_error "Failed to install lazynpm"
        exit 1
    fi
}

# Main execution
main() {
    install_go_tools
}

main "$@"