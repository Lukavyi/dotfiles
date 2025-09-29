#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

link_global_ignore() {
    local global_ignore="$DOTFILES_DIR/.stow-global-ignore"
    local target="$HOME/.stow-global-ignore"

    if [[ -f "$global_ignore" ]]; then
        echo "  Linking .stow-global-ignore to home directory..."

        # Create or update symlink (force overwrites existing)
        ln -sf "$global_ignore" "$target"
        print_success ".stow-global-ignore linked to home directory"
    fi
}

install_stow_configs() {
    echo "Linking configuration files..."

    # Link global stow ignore file first
    link_global_ignore

    # Ensure ~/.config exists to prevent stow from folding it into a single symlink
    mkdir -p ~/.config

    # Change to dotfiles directory for stow to work properly
    cd "$DOTFILES_DIR"

    # Stow each directory with --adopt to handle existing files (excluding git)
    for dir in zsh tmux p10k config; do
        if [[ -d "$dir" ]]; then
            echo "  Stowing $dir..."
            # Adopt existing files into our repo
            stow --adopt "$dir"
        fi
    done

    # Stow git and personal directories for personal profiles only
    if [[ "$PROFILE" == "personal" ]]; then
        if [[ -d "git" ]]; then
            echo "  Stowing git..."
            stow --adopt git
            print_success "Git configuration linked"
        fi

        if [[ -d "personal" ]]; then
            echo "  Stowing personal directory..."
            stow --adopt personal
            print_success "Personal profile configurations linked"
        fi
    fi

    # Show what was adopted
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        print_warning "Existing configs were adopted into the repository."
        echo ""
        echo "Review changes with:"
        echo "  git status           # See what changed"
        echo "  git diff             # See detailed differences"
        echo ""
        echo "To keep your dotfiles version:"
        echo "  git restore <file>   # Revert specific files"
        echo "  git restore .        # Revert all changes"
        echo ""
        echo "To keep the adopted version:"
        echo "  git add <file>       # Stage specific files"
        echo "  git add .            # Stage all changes"
        echo ""
    fi

    print_success "Configuration files linked"
}

# Main execution
main() {
    print_info "Setting up stow configurations..."

    # Ensure Homebrew is available (so stow and git are in PATH)
    ensure_brew

    # Check if stow is installed
    if ! command -v stow &>/dev/null; then
        print_error "GNU Stow is not installed. Please install it first."
        exit 1
    fi

    install_stow_configs
    print_success "Stow configurations complete"
}

main "$@"