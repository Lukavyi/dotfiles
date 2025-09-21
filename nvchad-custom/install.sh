#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
NVCHAD_CUSTOM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if nvim is installed
if ! command -v nvim &>/dev/null; then
    echo -e "${YELLOW}⚠ Neovim is not installed. Skipping NvChad setup.${NC}"
    exit 0
fi

echo -e "${BLUE}Setting up NvChad with custom configuration...${NC}"

# Check if ~/.config/nvim already exists
if [[ -d ~/.config/nvim ]]; then
    # Check if it's a symlink (from stow)
    if [[ -L ~/.config/nvim ]]; then
        echo -e "${YELLOW}⚠ ~/.config/nvim is a symlink (managed by stow)${NC}"
        echo "  Remove it first if you want to install NvChad:"
        echo "  stow -D config"
        exit 1
    else
        # Just remove it - install.sh already backed it up if needed
        echo "Removing existing nvim config (already backed up by install.sh if needed)..."
        rm -rf ~/.config/nvim
    fi
fi

# Clone fresh NvChad starter
echo "Installing NvChad starter..."
git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1

# Apply custom configurations
echo "Applying custom configurations..."
cp "$NVCHAD_CUSTOM_DIR/chadrc.lua" ~/.config/nvim/lua/chadrc.lua
cp "$NVCHAD_CUSTOM_DIR/mappings.lua" ~/.config/nvim/lua/mappings.lua
cp "$NVCHAD_CUSTOM_DIR/options.lua" ~/.config/nvim/lua/options.lua
cp "$NVCHAD_CUSTOM_DIR/conform.lua" ~/.config/nvim/lua/configs/conform.lua
cp "$NVCHAD_CUSTOM_DIR/plugins.lua" ~/.config/nvim/lua/plugins/init.lua

echo -e "${GREEN}✓ NvChad installed with custom configuration${NC}"
echo -e "${YELLOW}  Run 'nvim' and wait for plugins to install on first launch${NC}"