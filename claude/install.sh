#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Install Claude configurations using stow

echo "Setting up Claude configurations..."

# Use stow to symlink all claude configs
# This keeps all files in sync automatically - no manual copying needed
if command -v stow >/dev/null 2>&1; then
    # Stow from the parent dotfiles directory (standard pattern)
    # --adopt will take any existing files in ~/.claude/ and move them into the repo
    # This lets you see diffs (git diff) and decide whether to keep or revert changes
    cd "$DOTFILES_DIR"
    stow --adopt claude

    echo "✓ Claude Code configurations symlinked to ~/.claude/"
    echo "  - CLAUDE.md (system-wide instructions)"
    echo "  - settings.json (Claude Code settings)"
    echo "  - .mcp.json (MCP server configurations)"
    echo ""
    echo "  Use 'claudem' or 'cm' to run with MCPs, 'claude' or 'c' without"
else
    echo "✗ stow not found. Please install stow first:"
    echo "  macOS: brew install stow"
    echo "  Linux: sudo apt install stow"
    exit 1
fi

echo ""
echo "Claude Code configuration installed successfully!"
echo "Note: Files are now symlinked - any edits sync automatically!"