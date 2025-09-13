#!/bin/bash

# Auto-generate apps.yml from Applications folder and check installation status
# This script scans /Applications/, categorizes apps by source, and shows what's missing

echo "Generating application inventory and checking status..."
echo "======================================================"

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

echo -e "${BLUE}Scanning /Applications/ and categorizing by installation source...${NC}"

# Get lists of apps by source
homebrew_casks=$(brew list --cask 2>/dev/null | sort)
appstore_apps=$(mas list 2>/dev/null | awk '{$1=""; print $0}' | sed 's/^ //' | sort)

# Initialize arrays
declare -a homebrew_list
declare -a appstore_list  
declare -a manual_list

# First, add all Homebrew casks (including CLI tools that don't appear in /Applications/)
while IFS= read -r cask; do
    if [ -n "$cask" ]; then
        homebrew_list+=("$cask")
    fi
done <<< "$homebrew_casks"

# Scan Applications folder for apps not already tracked by Homebrew
for app_path in /Applications/*.app; do
    if [ -d "$app_path" ] || [ -L "$app_path" ]; then
        app_name=$(basename "$app_path" .app)
        
        # Check if this app is installed via Homebrew cask by trying name transformations
        cask_found=false
        
        # Special case: 1Password GUI app should not be confused with 1password-cli
        if [[ "$app_name" == "1Password" ]]; then
            cask_found=false
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
        
        # Skip if already tracked by Homebrew
        if [ "$cask_found" = true ]; then
            continue
        fi
        
        # Check if it's from App Store (exact app name match)
        appstore_match=$(echo "$appstore_apps" | grep "^${app_name} " | head -1)
        if [[ -n "$appstore_match" ]]; then
            # Verify it's an exact match (not a partial match like "1Password" matching "1Password for Safari")
            appstore_app_name=$(echo "$appstore_match" | sed 's/ (.*)//')
            if [[ "$appstore_app_name" == "$app_name" ]]; then
                # Check if already added to avoid duplicates
                if [[ ! " ${appstore_list[@]} " =~ " ${appstore_match} " ]]; then
                    appstore_list+=("$appstore_match")
                fi
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

# Also scan for non-.app files and directories in /Applications/
for item in /Applications/*; do
    if [ -d "$item" ]; then
        item_name=$(basename "$item")
        # Skip system directories but include others
        if [[ "$item_name" != "Utilities" ]] && [[ "$item_name" != *.app ]]; then
            # Check if it's not already in our lists
            if [[ ! " ${manual_list[@]} " =~ " ${item_name} " ]]; then
                # Special cases for known directory-based apps
                if [[ "$item_name" == "Setapp" ]] || [[ "$item_name" == "Datacolor" ]]; then
                    manual_list+=("$item_name")
                fi
            fi
        fi
        
        # Include Utilities as it was in the original list
        if [[ "$item_name" == "Utilities" ]]; then
            if [[ ! " ${manual_list[@]} " =~ " ${item_name} " ]]; then
                manual_list+=("$item_name")
            fi
        fi
    fi
done

# Generate apps.yml
cat > apps/apps.yml << 'EOF'
# Application inventory organized by installation method
# Auto-generated from /Applications/ folder

homebrew_cask:
EOF

# Add homebrew casks
for app in "${homebrew_list[@]}"; do
    echo "  - $app" >> apps/apps.yml
done

echo "" >> apps/apps.yml
echo "appstore:" >> apps/apps.yml

# Add app store apps  
for app in "${appstore_list[@]}"; do
    echo "  - \"$app\"" >> apps/apps.yml
done

echo "" >> apps/apps.yml
echo "manual:" >> apps/apps.yml

# Add manual apps
for app in "${manual_list[@]}"; do
    echo "  - \"$app\"" >> apps/apps.yml
done

echo -e "${GREEN}✓ Generated apps/apps.yml with ${#homebrew_list[@]} homebrew, ${#appstore_list[@]} appstore, and ${#manual_list[@]} manual apps${NC}"

echo -e "\n${BLUE}Checking installation status...${NC}"

# Check Homebrew cask apps
echo -e "\n${YELLOW}Homebrew Cask Applications:${NC}"
for app in "${homebrew_list[@]}"; do
    if brew list --cask "$app" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $app"
    else
        echo -e "${RED}✗${NC} $app (not installed via Homebrew)"
    fi
done

# Check App Store apps
echo -e "\n${YELLOW}Mac App Store Applications:${NC}"
for app in "${appstore_list[@]}"; do
    # Extract app name (remove version info in parentheses)
    app_name=$(echo "$app" | sed 's/ (.*)//')
    if [ -d "/Applications/$app_name.app" ]; then
        echo -e "${GREEN}✓${NC} $app"
    else
        echo -e "${RED}✗${NC} $app (not installed)"
    fi
done

# Check manually installed apps
echo -e "\n${YELLOW}Manually Installed Applications:${NC}"
echo "(These need to be downloaded and installed manually)"
for app in "${manual_list[@]}"; do
    if [ -d "/Applications/$app.app" ] || [ -L "/Applications/$app.app" ] || [ -d "/Applications/$app" ]; then
        echo -e "${GREEN}✓${NC} $app (installed)"
    else
        echo -e "${RED}✗${NC} $app (not installed)"
    fi
done

echo -e "\n======================================================"
echo "Installation instructions:"
echo "1. Run: brew bundle --file=brew/Brewfile"
echo "2. Manually install apps marked with ✗ from the manual section"
echo "3. Sign in to Mac App Store and install missing apps"
echo "4. Run this script again to update the inventory"