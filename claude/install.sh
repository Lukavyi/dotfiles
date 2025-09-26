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

# MCP servers configuration
# Workaround for GitHub issue #5037: MCP servers not loading from subdirectories
# https://github.com/anthropics/claude-code/issues/5037
if [ -f .mcp.json ]; then
    # Copy .mcp.json to ~/.claude/ directory with variable substitution
    # This ensures MCP servers are loaded properly when Claude starts
    envsubst '$HOME $OPENROUTER_API_KEY $OPENAI_API_KEY' < .mcp.json > ~/.claude/.mcp.json
    echo "✓ MCP configuration installed to ~/.claude/.mcp.json"
    echo "  Note: Shell aliases are configured to use 'claude --mcp-config ~/.claude/.mcp.json'"
fi

echo ""
echo "Claude Code configuration installed successfully!"
echo "Note: You may need to restart Claude Code for changes to take effect."