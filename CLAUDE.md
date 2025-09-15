# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a minimal personal dotfiles repository managed with GNU Stow for macOS and Linux. It used to be ~1,500 lines of complex bash scripts but has been simplified to ~150 lines total, focusing on what actually gets used.

**Important**: This repository contains personal information including git user credentials, SSH signing keys, and machine-specific configurations. It is intended solely for the owner's personal use across their own machines and should not be used as a template or shared with others.

## Common Commands

### Setup and Installation
```bash
# Full installation
./install.sh

# Manual installation
brew bundle --file=brew/Brewfile.macos  # macOS: Install all packages
brew bundle --file=brew/Brewfile.cli    # Linux/CLI: Install CLI tools only
stow zsh git tmux p10k config     # Link configurations
cd npm && npm install -g && cd .. # Install npm packages
cd claude && bash install.sh      # Install Claude config
```

### Backup and Update
```bash
# Backup current configuration
./backup.sh

# Preview what would be backed up
./backup.sh --dry-run

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

- **`install.sh`** (85 lines) - Simple installer that:
  - Installs Homebrew if needed
  - Runs `brew bundle` to install all packages
  - Links configs with stow (explicit list: zsh, git, tmux, p10k, config)
  - Runs special installers (npm, claude)
  - Checks macOS apps on macOS

- **`backup.sh`** (66 lines) - Minimal backup that:
  - Updates Brewfile.macos or Brewfile.cli based on OS
  - Backs up local zsh config
  - Updates apps inventory on macOS
  - Supports --dry-run to preview changes

- **`apps/check_apps.sh`** (191 lines) - macOS app tracker:
  - Scans /Applications/
  - Categorizes by source (brew, appstore, manual)
  - Generates apps.yml inventory
  - Shows installation status

### What Got Removed

The repository was drastically simplified by removing:
- **lib/** directory with 340+ lines of "framework" code
- Dynamic directory discovery (not needed for 10 directories)
- Pattern matching and auto-detection
- Hooks, manifests, and configuration files
- Interactive/verbose modes
- Complex backup functions (SSH, GPG, history, etc.)
- Support for multiple Linux distributions

## Directory Structure

- **`apps/`** - macOS application tracking
- **`brew/`** - Brewfile.cli (CLI tools) and Brewfile.macos (includes CLI + GUI)
- **`claude/`** - Claude Code CLI configuration
- **`config/`** - .config/ subdirectories (bat, gh, nvim, etc.)
- **`git/`** - Git configuration
- **`npm/`** - Global npm packages
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
2. Add it to the stow list in `install.sh` (line ~48)
3. That's it

### Add a new Homebrew package
1. Run `brew install <package>`
2. Run `./backup.sh` to update Brewfile.macos or Brewfile.cli
3. Commit the changes

### Check what's installed on macOS
```bash
cd apps && ./check_apps.sh
```

### Machine-specific configuration
Use `~/.zshrc.local` for machine-specific settings (created automatically by install.sh)