# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a minimal personal dotfiles repository managed with GNU Stow for macOS and Linux. It used to be ~1,500 lines of complex bash scripts but has been simplified to ~150 lines total, focusing on what actually gets used.

**Important**: This repository contains personal information including git user credentials, SSH signing keys, and machine-specific configurations. It is intended solely for the owner's personal use across their own machines and should not be used as a template or shared with others.

## Common Commands

### Setup and Installation
```bash
# Full installation (interactive mode - choose what to install)
./install.sh

# Non-interactive installation with profiles
./install.sh --non-interactive --work     # Work profile: work-safe tools only (default)
./install.sh --non-interactive --personal # Personal profile: auto-detects OS for appropriate tools

# Manual installation
brew bundle --file=brew/Brewfile.basic    # Work profile: work-safe tools only
brew bundle --file=brew/Brewfile.personal # Personal CLI tools (add to basic)
brew bundle --file=brew/Brewfile.macos    # macOS GUI apps and Mac App Store items
stow zsh git tmux p10k config     # Link configurations
cd nvm && bash install.sh && cd .. # Install Node Version Manager
cd go-tools && bash install.sh && cd .. # Install Go-based tools (lazynpm)
cd npm && npm install -g && cd .. # Install npm packages
cd nvchad-custom && bash install.sh && cd .. # Install NvChad custom config
cd claude && bash install.sh      # Install Claude config
```

### Backup and Update
```bash
# Interactive mode (choose backup from menu in the installer)
./install.sh

# Check macOS applications (macOS only)
./apps/check_apps.sh
```

### Configuration Management
```bash
# Link configurations
stow zsh git tmux p10k config

# Remove configurations
stow -D zsh git tmux p10k config
```

## Scripts

### Core Scripts (simplified)

- **`install.sh`** - Unified installer:
  - Default: Interactive mode with Node.js/Ink UI
    - Choose between installation or backup mode in the UI
    - Select specific components to install/backup
  - Installation options:
    - `--non-interactive` - Install everything automatically
    - Installs Homebrew if needed
    - Runs special installers (nvm, npm, nvchad-custom, claude)
    - Links configs with stow
    - Automatically backs up after installation in non-interactive mode
  - Backup functionality:
    - Available through the interactive UI menu
    - Updates Brewfile.basic, Brewfile.personal, and Brewfile.macos based on installed packages
    - Updates apps inventory on macOS

- **`apps/check_apps.sh`** - macOS app tracker:
  - Scans /Applications/
  - Categorizes by source (brew, appstore, manual)
  - Generates apps.yml inventory
  - Shows installation status

### What Got Simplified

The repository was drastically simplified:
- **lib/** reduced from 340+ lines to just common.sh (66 lines)
- Dynamic directory discovery removed (not needed for explicit directories)
- Pattern matching and auto-detection removed
- Hooks, manifests, and configuration files removed
- Complex backup functions (SSH, GPG, history, etc.) removed
- Support for multiple Linux distributions simplified
- Interactive mode reimplemented with modern Node.js/Ink UI

## Directory Structure

- **`apps/`** - macOS application tracking
  - `check_apps.sh` - Scans and inventories installed apps
  - `backup.sh` - Updates apps.yml inventory
- **`brew/`** - Homebrew configuration
  - `Brewfile.basic` - Work-safe essential tools
  - `Brewfile.personal` - Personal CLI tools (claude-squad, pass, opencode, ffmpeg, libusb)
  - `Brewfile.macos` - macOS GUI apps (casks) and Mac App Store items
  - `backup.sh` - Smart backup with deduplication
- **`claude/`** - Claude Code CLI configuration
  - `settings.json` - Claude Code settings (model, permissions, statusLine)
  - `.mcp.json` - MCP server configurations (playwright, chrome-devtools, zen)
  - `install.sh` - Copies configs to ~/.claude/ with environment variable expansion
  - Aliases: `claudem` (with MCPs) and `claude` (without MCPs)
- **`config/`** - .config/ subdirectories (bat, gh, nvim, etc.)
- **`git/`** - Git configuration
- **`go-tools/`** - Go-based tools (lazynpm installed via `go install`)
- **`installer/`** - Interactive installer UI (Ink-based TypeScript application)
  - Handles both installation and backup operations
  - Written in TypeScript with React/Ink
- **`lib/`** - Common utilities (common.sh for shared functions)
- **`npm/`** - Global npm packages
- **`nvchad-custom/`** - NvChad custom configuration files
- **`nvm/`** - Node Version Manager installation and setup
- **`p10k/`** - Powerlevel10k theme
- **`tmux/`** - Tmux configuration
- **`zsh/`** - Zsh with Oh My Zsh

## Philosophy

**Explicit > Clever**: The scripts now explicitly list directories to stow rather than discovering them. This makes the code obvious and easy to modify.

**YAGNI (You Aren't Gonna Need It)**: Removed features that sound useful but are rarely used in practice (interactive mode, verbose output, complex backup logic).

**Maintainable**: The entire codebase can be understood in 5 minutes. When something breaks, it's immediately obvious where to look.

## Common Tasks

### Add a new tool directory
1. Create the directory with your dotfiles
2. Add it to the installation list in `install.sh` (run_all_installations function)
3. If using the interactive installer, add it to `installer/source/config.ts`
4. That's it

### Add a new Homebrew package
1. Run `brew install <package>`
2. Run `./install.sh` and choose backup from the menu to update Brewfiles
3. Commit the changes

### Check what's installed on macOS
```bash
cd apps && ./check_apps.sh
```

### Use Claude Code CLI with/without MCPs
```bash
# Basic Claude (no MCPs)
claude
c         # Short alias

# Claude with MCPs (playwright, chrome-devtools, zen)
claudem
cm        # Short alias
```

### Machine-specific configuration
Use `~/.zshrc.local` for machine-specific settings (created automatically by install.sh)
- Don't add terminal commands that asks user stuff in @install.sh cause in some cases it's being built in docker