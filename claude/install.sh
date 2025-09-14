#!/bin/bash

# Install Claude configurations

echo "Setting up Claude configurations..."

# Claude Code CLI settings (including MCP servers)
if [ -f settings.json ]; then
    mkdir -p ~/.claude
    # Expand only $HOME variable in settings.json, preserving $schema
    envsubst '$HOME' < settings.json > ~/.claude/settings.json
    echo "✓ Claude Code settings installed to ~/.claude/settings.json"
fi

echo ""
echo "Claude Code configuration installed successfully!"
echo "Note: You may need to restart Claude Code for changes to take effect."