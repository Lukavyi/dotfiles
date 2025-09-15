#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Handle arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [--dry-run]"
    echo ""
    echo "Backup current machine configurations to the dotfiles repository."
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be backed up without making changes"
    echo "  --help       Show this help message"
    exit 0
fi

DRY_RUN=false
[[ "$1" == "--dry-run" || "$1" == "-n" ]] && DRY_RUN=true

echo -e "${BLUE}Backing up configurations...${NC}"

# Backup Homebrew packages to appropriate Brewfile based on OS
if command -v brew &>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        BREWFILE="brew/Brewfile.macos"
    else
        BREWFILE="brew/Brewfile.cli"
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "  [DRY-RUN] Would update $BREWFILE"
    else
        brew bundle dump --file=$BREWFILE --force
        echo -e "${GREEN}✓${NC} Homebrew packages backed up to $BREWFILE"
    fi
fi

# Backup local zsh config if it exists
if [[ -f ~/.zshrc.local ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "  [DRY-RUN] Would backup ~/.zshrc.local"
    else
        cp ~/.zshrc.local zsh/.zshrc.local.example 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Local zsh config backed up"
    fi
fi

# For macOS: update apps inventory
if [[ "$OSTYPE" == "darwin"* ]] && [[ -f apps/check_apps.sh ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "  [DRY-RUN] Would update apps/apps.yml"
    else
        echo "Updating macOS apps inventory..."
        (cd apps && bash check_apps.sh > /dev/null 2>&1)
        echo -e "${GREEN}✓${NC} macOS apps inventory updated"
    fi
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}Dry-run complete. Run without --dry-run to execute backup.${NC}"
else
    echo ""
    echo -e "${GREEN}✓ Backup complete!${NC}"
    echo ""
    echo "Run 'git status' to see what changed"
    echo "Run 'git diff' to review changes before committing"
fi