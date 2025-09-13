# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow for cross-platform shell and development environment configuration. It supports both macOS and Linux with platform-specific package management and shared configuration files.

**Important**: This repository contains personal information including git user credentials, SSH signing keys, and machine-specific configurations. It is intended solely for the owner's personal use across their own machines and should not be used as a template or shared with others.

## Common Commands

### Setup and Installation
```bash
# Full automated installation (recommended)
./install.sh

# Manual installation - macOS
brew bundle --file=brew/Brewfile
cd npm && npm install -g && cd ..
stow zsh git

# Manual installation - Linux
# Install system build tools first
sudo apt-get install build-essential  # Debian/Ubuntu
# or: sudo dnf groupinstall "Development Tools"  # Fedora
# or: sudo pacman -S base-devel  # Arch

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages and configurations
brew bundle --file=brew/Brewfile
cd npm && npm install -g && cd ..
stow zsh git

# Install configurations only
stow */              # Safe bulk operation (ignores non-config dirs)
# or: stow zsh git    # Selective approach
```

### Package Management
```bash
# Update Brewfile with currently installed packages (cross-platform)
brew bundle dump --file=brew/Brewfile --force

# Check which packages are installed
brew bundle check --file=brew/Brewfile

# Generate application inventory and check status (macOS)
./apps/check_apps.sh
```

### Configuration Management
```bash
# Remove symlinks (uninstall)
stow -D */           # Remove all configurations
# or: stow -D zsh git  # Selective removal

# Re-link configurations
stow */              # Link all configurations
# or: stow -v zsh git  # Selective linking

# Install Claude configuration
cd claude && bash install.sh && cd ..
```

## Architecture and Structure

### Key Directories

- **`apps/`** - Application inventory and tracking system for macOS applications
  - `check_apps.sh` auto-generates `apps.yml` from `/Applications/` and checks installation status
  - Apps are categorized by installation source (homebrew_cask, appstore, manual)
  
- **`brew/`** - Cross-platform package management via Homebrew
  - `Brewfile` defines CLI tools for both macOS and Linux, plus GUI apps and Mac App Store apps for macOS
  
- **`claude/`** - Claude Code CLI configuration with MCP server setup
  - Contains settings.json and install script for `~/.claude/settings.json`
  
- **`git/`** - Cross-platform Git configuration using Stow
  
- **`npm/`** - Global Node.js package definitions

- **`zsh/`** - Cross-platform Zsh shell configuration
  - Supports machine-specific local configs via `~/.zshrc.local` and `~/.zprofile.local`

### Installation Flow

1. **OS Detection** - Main installer detects macOS/Linux
2. **Dependencies** - Installs Stow via appropriate package manager
3. **System Packages** - Linux: installs build tools and system packages
4. **Homebrew Setup** - Installs Homebrew on both platforms
5. **Package Installation** - Installs CLI tools and packages via unified Brewfile
6. **Stow Linking** - Creates symlinks for shared configurations (zsh, git)
7. **Claude Setup** - Installs Claude Code CLI settings if present
8. **Local Templates** - Creates machine-specific configuration templates

### Multi-Machine Strategy

The repository supports multiple machines through:
- Machine-specific branches (e.g., `hostname-20240101`)
- Local configuration files (`~/.zshrc.local`, `~/.zprofile.local`)
- Platform-specific package lists
- Hostname-based conditionals in shell configs

### Application Management System

Comprehensive tracking of macOS applications:
- **Automated categorization** by installation source
- **Status checking** with `./apps/check_apps.sh`
- **Manual app tracking** for applications not available via package managers
- **Inventory updates** via system profiler integration