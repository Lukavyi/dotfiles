#!/bin/bash

# Auto-generate apps.yml with only manually installed applications
# This script scans /Applications/ and excludes apps managed by brew/cask/mas

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Scanning for manually installed applications..."
echo "====================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo -e "${RED}Error: yq is not installed. Run 'brew install yq' first.${NC}"
    exit 1
fi

echo -e "${BLUE}Scanning /Applications/ for apps not managed by brew or mas...${NC}"

# Get lists of apps managed by package managers (to exclude them)
homebrew_casks=$(brew list --cask 2>/dev/null | sort)
appstore_apps=$(mas list 2>/dev/null | awk '{$1=""; print $0}' | sed 's/^ //' | sort)

# Initialize array for manual apps only
declare -a manual_list

# Scan Applications folder for apps not managed by brew or mas
for app_path in /Applications/*.app; do
    if [ -d "$app_path" ] || [ -L "$app_path" ]; then
        app_name=$(basename "$app_path" .app)

        # Check if this app is installed via Homebrew cask
        cask_found=false

        # Special case: 1Password GUI app (handled by 1password cask)
        if [[ "$app_name" == "1Password" ]]; then
            if echo "$homebrew_casks" | grep -q "^1password$"; then
                cask_found=true
            fi
        else
            # Try exact match first (lowercase, spaces to hyphens)
            cask_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            if echo "$homebrew_casks" | grep -q "^${cask_name}$"; then
                cask_found=true
            fi

            # Try with "desktop" suffix for some apps
            if [ "$cask_found" = false ] && [[ "$app_name" == "Docker" ]]; then
                if echo "$homebrew_casks" | grep -q "^docker-desktop$"; then
                    cask_found=true
                fi
            fi
        fi

        # Skip if managed by Homebrew
        if [ "$cask_found" = true ]; then
            continue
        fi

        # Check if it's from App Store
        appstore_match=$(echo "$appstore_apps" | grep "^${app_name} " | head -1)
        if [[ -n "$appstore_match" ]]; then
            appstore_app_name=$(echo "$appstore_match" | sed 's/ (.*)//')
            if [[ "$appstore_app_name" == "$app_name" ]]; then
                # Skip if managed by mas
                continue
            fi
        fi

        # Skip system apps and utilities
        if [[ "$app_name" == "Utilities" || "$app_name" == "System Preferences" ]]; then
            continue
        fi

        # Everything else is manual (avoid duplicates)
        if [[ ! " ${manual_list[@]} " =~ " ${app_name} " ]]; then
            manual_list+=("$app_name")
        fi
    fi
done

# Also scan for directories containing .app files in /Applications/
for item in /Applications/*; do
    if [ -d "$item" ]; then
        item_name=$(basename "$item")

        # Skip .app bundles themselves and Setapp (handled separately)
        if [[ "$item_name" != *.app ]] && [[ "$item_name" != "Setapp" ]]; then
            # Check if directory contains any .app files
            if ls "$item"/*.app &>/dev/null 2>&1; then
                # This directory contains apps, add it to manual list if not already there
                if [[ ! " ${manual_list[@]} " =~ " ${item_name} " ]]; then
                    manual_list+=("$item_name")
                fi
            fi
        fi
    fi
done

# Scan Setapp directory for apps if it exists
declare -a setapp_list
if [ -d "/Applications/Setapp" ]; then
    echo -e "${BLUE}Scanning /Applications/Setapp/ for Setapp-installed apps...${NC}"
    for app_path in /Applications/Setapp/*.app; do
        if [ -d "$app_path" ]; then
            app_name=$(basename "$app_path" .app)
            setapp_list+=("$app_name")
        fi
    done
fi

# Generate apps.yml with manual and Setapp apps
cat > "$SCRIPT_DIR/apps.yml" << 'EOF'
# Manually installed applications not managed by brew/cask/mas
# Auto-generated from /Applications/ folder
# Apps in Brewfile.macos are excluded from this list

manual:
EOF

# Add manual apps
if [ ${#manual_list[@]} -eq 0 ]; then
    echo "  []  # No manual apps found" >> "$SCRIPT_DIR/apps.yml"
else
    for app in "${manual_list[@]}"; do
        echo "  - \"$app\"" >> "$SCRIPT_DIR/apps.yml"
    done
fi

# Add Setapp section if there are Setapp apps
if [ ${#setapp_list[@]} -gt 0 ]; then
    cat >> "$SCRIPT_DIR/apps.yml" << 'EOF'

# Apps installed via Setapp
setapp:
EOF
    for app in "${setapp_list[@]}"; do
        echo "  - \"$app\"" >> "$SCRIPT_DIR/apps.yml"
    done
fi

echo -e "${GREEN}✓ Generated apps/apps.yml${NC}"
echo -e "  • ${#manual_list[@]} manual apps"
if [ ${#setapp_list[@]} -gt 0 ]; then
    echo -e "  • ${#setapp_list[@]} Setapp apps"
fi
echo -e "  (Excluded: $(brew list --cask 2>/dev/null | wc -l | xargs) brew casks and $(mas list 2>/dev/null | wc -l | xargs) App Store apps already in Brewfile)"

if [ ${#manual_list[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Manually Installed Applications:${NC}"
    echo "(These apps are not managed by brew or mas)"
    for app in "${manual_list[@]}"; do
        if [ -d "/Applications/$app.app" ] || [ -L "/Applications/$app.app" ] || [ -d "/Applications/$app" ]; then
            echo -e "${GREEN}✓${NC} $app"
        else
            echo -e "${RED}✗${NC} $app (not found - may have been removed)"
        fi
    done
fi

if [ ${#setapp_list[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Setapp Applications:${NC}"
    echo "(These apps are installed via Setapp)"
    for app in "${setapp_list[@]}"; do
        if [ -d "/Applications/Setapp/$app.app" ]; then
            echo -e "${GREEN}✓${NC} $app"
        else
            echo -e "${RED}✗${NC} $app (not found - may have been removed)"
        fi
    done
fi

if [ ${#manual_list[@]} -eq 0 ] && [ ${#setapp_list[@]} -eq 0 ]; then
    echo -e "\n${GREEN}All installed apps are managed by brew or mas!${NC}"
fi

echo -e "\n======================================================"
echo "Notes:"
echo "• Brew-managed apps: See brew/Brewfile.macos"
echo "• To install all brew/mas apps: brew bundle --file=brew/Brewfile.macos"
if [ ${#manual_list[@]} -gt 0 ]; then
    echo "• Manual apps listed above need to be installed separately"
fi
if [ ${#setapp_list[@]} -gt 0 ]; then
    echo "• Setapp apps require an active Setapp subscription"
fi