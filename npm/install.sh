#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

# Install global npm packages from package.json
print_info "Installing global npm packages from package.json..."

# Ensure Homebrew is available (jq is needed for install-global script)
ensure_brew

# Change to the npm directory
cd "$(dirname "$0")"

# Check if package.json exists
if [[ ! -f "package.json" ]]; then
    print_error "package.json not found in npm directory"
    exit 1
fi

# Try to load NVM first to ensure NVM's Node/npm takes precedence over Docker/system versions
export NVM_DIR="$HOME/.nvm"
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    source "/opt/homebrew/opt/nvm/nvm.sh"
elif [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    source "/usr/local/opt/nvm/nvm.sh"
elif [[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ]]; then
    source "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
fi

# Check if npm is available (from NVM or fallback to system)
if ! command -v npm &>/dev/null; then
    print_error "npm is not installed. Please install Node.js via NVM first"
    print_warning "Run: nvm install --lts && nvm use --lts"
    exit 1
fi

# Install packages globally
if npm run install-global; then
    print_success "Global npm packages installed successfully!"
    print_info "Run 'npm list -g --depth=0' to see installed packages"
else
    print_error "Failed to install npm packages"
    print_warning "You may need to run with sudo or fix npm permissions"
    exit 1
fi