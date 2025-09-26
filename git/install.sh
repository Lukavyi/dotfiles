#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Setting up git configuration..."

# Generate gitconfig.local from pass if pass is available
if command -v pass &>/dev/null; then
    echo "Checking for git credentials in pass..."

    # Get git user info from pass if available
    GIT_USER_NAME="$(pass show git/user.name 2>/dev/null || echo '')"
    GIT_USER_EMAIL="$(pass show git/user.email 2>/dev/null || echo '')"
    GIT_SIGNING_KEY="$(pass show git/signingkey 2>/dev/null || echo '')"

    # Only generate if we have the values
    if [[ -n "$GIT_USER_NAME" ]] && [[ -n "$GIT_USER_EMAIL" ]]; then
        GITCONFIG_LOCAL="$HOME/.gitconfig.local"
        TEMP_CONFIG=$(mktemp)

        # Build the new config
        cat > "$TEMP_CONFIG" << EOF
[user]
	name = $GIT_USER_NAME
	email = $GIT_USER_EMAIL
EOF

        # Add signing key if available
        if [[ -n "$GIT_SIGNING_KEY" ]]; then
            echo "	signingkey = $GIT_SIGNING_KEY" >> "$TEMP_CONFIG"
        fi

        # Only update if different from existing
        if ! cmp -s "$TEMP_CONFIG" "$GITCONFIG_LOCAL" 2>/dev/null; then
            cp "$TEMP_CONFIG" "$GITCONFIG_LOCAL"
            echo -e "${GREEN}✓ Generated .gitconfig.local from pass${NC}"
        else
            echo -e "${GREEN}✓ .gitconfig.local is up to date${NC}"
        fi

        rm -f "$TEMP_CONFIG"
    else
        echo -e "${YELLOW}⚠ Git credentials not found in pass${NC}"
        echo "  To set them up, run:"
        echo "    pass insert git/user.name"
        echo "    pass insert git/user.email"
        echo "    pass insert git/signingkey  # optional"
    fi
else
    # If pass is not available, check if .gitconfig.local exists
    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
        echo -e "${YELLOW}⚠ No .gitconfig.local found${NC}"
        echo "  Copy git/.gitconfig.local.example to ~/.gitconfig.local and customize it"
    else
        echo -e "${GREEN}✓ Using existing .gitconfig.local${NC}"
    fi
fi