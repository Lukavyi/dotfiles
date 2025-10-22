#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Claude configurations

echo "Setting up Claude configurations..."

# Claude Code CLI settings (including MCP servers)
if [ -f "$SCRIPT_DIR/settings.json" ]; then
    mkdir -p ~/.claude
    # Expand only $HOME variable in settings.json, preserving $schema
    envsubst '$HOME' < "$SCRIPT_DIR/settings.json" > ~/.claude/settings.json
    echo "✓ Claude Code settings installed to ~/.claude/settings.json"
fi

# MCP servers configuration
# Workaround for GitHub issue #5037: MCP servers not loading from subdirectories
# https://github.com/anthropics/claude-code/issues/5037
if [ -f "$SCRIPT_DIR/.mcp.json" ]; then
    # Copy .mcp.json to ~/.claude/ directory with variable substitution
    # This ensures MCP servers are loaded properly when Claude starts
    envsubst '$HOME' < "$SCRIPT_DIR/.mcp.json" > ~/.claude/.mcp.json
    echo "✓ MCP configuration installed to ~/.claude/.mcp.json"
    echo "  Use 'claudem' or 'cm' to run with MCPs, 'claude' or 'c' without"
fi

echo ""
echo "Claude Code configuration installed successfully!"
echo "Note: You may need to restart Claude Code for changes to take effect."