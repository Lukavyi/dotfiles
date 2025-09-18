#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install global npm packages from package.json
echo -e "${BLUE}Installing global npm packages from package.json...${NC}"

# Change to the npm directory
cd "$(dirname "$0")"

# Check if package.json exists
if [[ ! -f "package.json" ]]; then
    echo -e "${RED}✗ package.json not found in npm directory${NC}"
    exit 1
fi

# Check if npm is available
if ! command -v npm &>/dev/null; then
    echo -e "${RED}✗ npm is not installed. Please install Node.js/npm first${NC}"
    exit 1
fi

# Install packages globally
if npm run install-global; then
    echo -e "${GREEN}✓ Global npm packages installed successfully!${NC}"
    echo -e "${BLUE}Run 'npm list -g --depth=0' to see installed packages${NC}"
else
    echo -e "${RED}✗ Failed to install npm packages${NC}"
    echo -e "${YELLOW}⚠ You may need to run with sudo or fix npm permissions${NC}"
    exit 1
fi