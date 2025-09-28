#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/lib/common.sh"

# Check if we're in a non-interactive environment (Docker, CI, etc.)
NON_INTERACTIVE=false
if [[ "$1" == "--non-interactive" || "$1" == "-n" || -n "$CI" || -n "$DOCKER_CONTAINER" || ! -t 0 ]]; then
    NON_INTERACTIVE=true
fi

# Function to run all installations in order (for non-interactive mode)
run_all_installations() {
    # Core
    bash "$DOTFILES_DIR/brew/install.sh"

    # Terminal & Shell
    bash "$DOTFILES_DIR/zsh/install.sh"
    bash "$DOTFILES_DIR/p10k/install.sh"
    bash "$DOTFILES_DIR/tmux/install.sh"

    # Configurations
    bash "$DOTFILES_DIR/config/install.sh"  # Stow
    bash "$DOTFILES_DIR/git/install.sh"
    bash "$DOTFILES_DIR/claude/install.sh"

    # Development
    bash "$DOTFILES_DIR/nvm/install.sh"
    bash "$DOTFILES_DIR/npm/install.sh"
    bash "$DOTFILES_DIR/nvchad-custom/install.sh"

    # macOS specific
    if [[ "$OS" == "macos" ]]; then
        bash "$DOTFILES_DIR/apps/check_apps.sh"
    fi
}

# Main installation logic
main() {
    printf "${BLUE}🏠 Setting up dotfiles for %s...${NC}\n" "$OS"
    [[ -n "$DISTRO" ]] && printf "${BLUE}  Linux distribution: %s${NC}\n" "$DISTRO"

    # Check we have the right directory structure
    if [[ ! -f "$DOTFILES_DIR/install.sh" ]]; then
        printf "${RED}✗ Dotfiles directory structure is incorrect${NC}\n"
        exit 1
    fi

    # Change to dotfiles directory for relative operations
    cd "$DOTFILES_DIR"

    # Run installation based on mode
    if [[ "$NON_INTERACTIVE" == false ]]; then
        # Interactive mode - require Node.js and use Ink installer
        if ! command -v node >/dev/null 2>&1; then
            printf "${RED}✗ Node.js is required to run the interactive installer.${NC}\n"
            printf "${YELLOW}Please install Node.js first: https://nodejs.org${NC}\n"
            printf "${YELLOW}Or use non-interactive mode: ./install.sh --non-interactive${NC}\n"
            exit 1
        fi

        printf "${BLUE}Starting interactive installer...${NC}\n"

        # Install dependencies and build if needed
        if [[ ! -d "$DOTFILES_DIR/installer/node_modules" ]]; then
            printf "${YELLOW}Installing installer dependencies...${NC}\n"
            (cd "$DOTFILES_DIR/installer" && npm install --silent)
        fi

        # Build the TypeScript installer
        printf "${YELLOW}Building installer...${NC}\n"
        (cd "$DOTFILES_DIR/installer" && npm run build --silent)

        # Run the Ink-based installer
        (cd "$DOTFILES_DIR/installer" && node dist/cli.js)
    else
        # Non-interactive mode - install everything
        printf "${CYAN}Running in non-interactive mode with all options...${NC}\n"
        echo ""
        printf "${BOLD}${BLUE}Starting installation...${NC}\n"
        echo ""

        run_all_installations

        echo ""
        printf "${GREEN}✓ Installation complete!${NC}\n"
        echo ""
        echo "Next steps:"
        echo "  1. Restart your shell or run: source ~/.zshrc"
        if [[ "$OS" == "macos" ]]; then
            echo "  2. Check missing apps: cd apps && ./check_apps.sh"
        fi
    fi
}

# Run main function
main "$@"