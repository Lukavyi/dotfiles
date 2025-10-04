#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Claude Code Router configuration

echo "Setting up Claude Code Router configuration..."

# Create config directory
mkdir -p ~/.claude-code-router

# Copy config.json with environment variable expansion
if [ -f "$SCRIPT_DIR/config.json" ]; then
    # Expand environment variables in config.json
    envsubst '$OPENROUTER_API_KEY $ANTHROPIC_API_KEY' < "$SCRIPT_DIR/config.json" > ~/.claude-code-router/config.json
    echo "✓ Claude Code Router config installed to ~/.claude-code-router/config.json"
    echo "  Use 'ccr code' to start the router"
    echo "  Use 'ccr ui' for interactive configuration"
    echo "  Use '/model' command to switch models dynamically"
else
    echo "✗ config.json not found in $SCRIPT_DIR"
    exit 1
fi

echo ""
echo "Claude Code Router configuration installed successfully!"
echo "Note: Make sure to have your API keys configured in pass:"
echo "  - pass show api/openrouter"
echo "  - pass show api/anthropic (optional)"
