#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

# Function to extract items from Brewfile
extract_items() {
    local file=$1
    local type=$2  # "tap", "brew", "cask", or "mas"

    if [[ -f "$file" ]]; then
        if [[ "$type" == "tap" ]]; then
            grep '^tap "' "$file" 2>/dev/null | sed -E 's/^tap "([^"]+)".*/\1/' | sort -u
        elif [[ "$type" == "mas" ]]; then
            # Extract just the app ID for comparison
            grep "^${type} " "$file" 2>/dev/null | sed -E 's/^mas "[^"]+", id: ([0-9]+).*/\1/' | sort -u
        else
            grep "^${type} " "$file" 2>/dev/null | sed -E "s/^${type} [\"']([^\"']+)[\"'].*/\1/" | sort -u
        fi
    fi
}

# Function to backup packages
backup_brew() {
    print_info "Collecting existing Brewfile entries..."

    # Collect all existing items from all Brewfiles
    EXISTING_TAPS=$(mktemp)
    EXISTING_BREWS=$(mktemp)
    EXISTING_CASKS=$(mktemp)
    EXISTING_MAS=$(mktemp)

    # Combine from all three Brewfiles
    for brewfile in "$DOTFILES_DIR/brew/Brewfile.basic" "$DOTFILES_DIR/brew/Brewfile.personal" "$DOTFILES_DIR/brew/Brewfile.macos"; do
        extract_items "$brewfile" "tap" >> "$EXISTING_TAPS"
        extract_items "$brewfile" "brew" >> "$EXISTING_BREWS"
        extract_items "$brewfile" "cask" >> "$EXISTING_CASKS"
        extract_items "$brewfile" "mas" >> "$EXISTING_MAS"
    done

    # Sort and deduplicate
    sort -u "$EXISTING_TAPS" -o "$EXISTING_TAPS"
    sort -u "$EXISTING_BREWS" -o "$EXISTING_BREWS"
    sort -u "$EXISTING_CASKS" -o "$EXISTING_CASKS"
    sort -u "$EXISTING_MAS" -o "$EXISTING_MAS"

    print_info "Getting current system state..."

    # Get current system state
    SYSTEM_DUMP=$(mktemp)
    brew bundle dump --file="$SYSTEM_DUMP" --force

    # Extract current system items
    SYSTEM_TAPS=$(mktemp)
    SYSTEM_BREWS=$(mktemp)
    SYSTEM_CASKS=$(mktemp)
    SYSTEM_MAS=$(mktemp)

    extract_items "$SYSTEM_DUMP" "tap" > "$SYSTEM_TAPS"
    extract_items "$SYSTEM_DUMP" "brew" > "$SYSTEM_BREWS"
    extract_items "$SYSTEM_DUMP" "cask" > "$SYSTEM_CASKS"
    extract_items "$SYSTEM_DUMP" "mas" > "$SYSTEM_MAS"

    # Find new items (in system but not in any Brewfile)
    NEW_TAPS=$(comm -13 "$EXISTING_TAPS" "$SYSTEM_TAPS")
    NEW_BREWS=$(comm -13 "$EXISTING_BREWS" "$SYSTEM_BREWS")
    NEW_CASKS=$(comm -13 "$EXISTING_CASKS" "$SYSTEM_CASKS")
    NEW_MAS=$(comm -13 "$EXISTING_MAS" "$SYSTEM_MAS")

    # Update Brewfile.basic with new taps and brews
    if [[ -n "$NEW_TAPS" ]] || [[ -n "$NEW_BREWS" ]]; then
        print_info "Adding new taps and brews to Brewfile.basic..."

        # Append new taps
        if [[ -n "$NEW_TAPS" ]]; then
            echo "" >> "$DOTFILES_DIR/brew/Brewfile.basic"
            echo "# New taps added by backup" >> "$DOTFILES_DIR/brew/Brewfile.basic"
            while IFS= read -r tap; do
                echo "tap \"$tap\"" >> "$DOTFILES_DIR/brew/Brewfile.basic"
            done <<< "$NEW_TAPS"
        fi

        # Append new brews
        if [[ -n "$NEW_BREWS" ]]; then
            echo "" >> "$DOTFILES_DIR/brew/Brewfile.basic"
            echo "# New formulae added by backup" >> "$DOTFILES_DIR/brew/Brewfile.basic"
            while IFS= read -r brew; do
                # Check if it's from a tap
                if [[ "$brew" == *"/"*"/"* ]]; then
                    echo "brew \"$brew\"" >> "$DOTFILES_DIR/brew/Brewfile.basic"
                else
                    echo "brew \"$brew\"" >> "$DOTFILES_DIR/brew/Brewfile.basic"
                fi
            done <<< "$NEW_BREWS"
        fi

        print_success "Updated Brewfile.basic with new CLI tools"
    fi

    # Update Brewfile.macos with new casks and mas
    if [[ "$OS" == "macos" ]] && ([[ -n "$NEW_CASKS" ]] || [[ -n "$NEW_MAS" ]]); then
        print_info "Adding new casks and MAS apps to Brewfile.macos..."

        # Append new casks
        if [[ -n "$NEW_CASKS" ]]; then
            echo "" >> "$DOTFILES_DIR/brew/Brewfile.macos"
            echo "# New casks added by backup" >> "$DOTFILES_DIR/brew/Brewfile.macos"
            while IFS= read -r cask; do
                echo "cask \"$cask\"" >> "$DOTFILES_DIR/brew/Brewfile.macos"
            done <<< "$NEW_CASKS"
        fi

        # Append new MAS apps
        if [[ -n "$NEW_MAS" ]]; then
            echo "" >> "$DOTFILES_DIR/brew/Brewfile.macos"
            echo "# New Mac App Store apps added by backup" >> "$DOTFILES_DIR/brew/Brewfile.macos"
            while IFS= read -r mas_id; do
                # Get the full line from system dump for this ID
                grep "mas.*id: $mas_id" "$SYSTEM_DUMP" >> "$DOTFILES_DIR/brew/Brewfile.macos"
            done <<< "$NEW_MAS"
        fi

        print_success "Updated Brewfile.macos with new GUI apps"
    fi

    # Clean up temp files
    rm -f "$EXISTING_TAPS" "$EXISTING_BREWS" "$EXISTING_CASKS" "$EXISTING_MAS"
    rm -f "$SYSTEM_TAPS" "$SYSTEM_BREWS" "$SYSTEM_CASKS" "$SYSTEM_MAS"
    rm -f "$SYSTEM_DUMP"

    # Summary
    echo ""
    echo "Backup complete!"
    if [[ -n "$NEW_TAPS" ]] || [[ -n "$NEW_BREWS" ]]; then
        echo "  ✓ Added new CLI tools to Brewfile.basic"
    fi
    if [[ "$OS" == "macos" ]] && ([[ -n "$NEW_CASKS" ]] || [[ -n "$NEW_MAS" ]]); then
        echo "  ✓ Added new GUI apps to Brewfile.macos"
    fi
    if [[ -z "$NEW_TAPS" ]] && [[ -z "$NEW_BREWS" ]] && [[ -z "$NEW_CASKS" ]] && [[ -z "$NEW_MAS" ]]; then
        echo "  ✓ No new packages found - everything is already tracked!"
    fi
}

# Main execution
if command -v brew &>/dev/null; then
    backup_brew
else
    print_warning "Homebrew not installed - skipping backup"
fi