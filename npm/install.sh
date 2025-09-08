#!/bin/bash

# Install global npm packages from package.json
echo "Installing global npm packages from package.json..."

# Change to the npm directory and install all dependencies globally
cd "$(dirname "$0")"
npm install -g

echo "Global npm packages installed successfully!"
echo "Run 'npm list -g --depth=0' to see installed packages"