# Dotfiles

Minimal, straightforward dotfiles managed with GNU Stow for macOS and Linux.

## About This Repository

A minimal, straightforward dotfiles setup for macOS and Linux. Feel free to fork and customize!

### ⚠️ Initial Setup Required
After installation, you'll need to configure your personal git settings in `~/.gitconfig.local`:
- Your name and email for commits
- SSH signing key (if using commit signing)

The installer will create this file from the template (`git/.gitconfig.local.example`) and remind you to edit it.

## Installation

### Quick Start (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/Lukavyi/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Run the automated installer:
```bash
./install.sh
```

The installer will:
- Install Homebrew (if needed)
- Install packages from profile-specific Brewfiles
- Link configurations with stow
- Set up special installers (npm, claude)
- Check macOS apps (on macOS only)

### Manual Installation

If you prefer to see each step:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages (including stow)
brew bundle --file=brew/Brewfile.basic    # Work profile (work-safe tools only)
brew bundle --file=brew/Brewfile.personal # Personal CLI tools (add to basic)
brew bundle --file=brew/Brewfile.macos    # macOS GUI apps (personal macOS only)

# Link configurations
stow zsh git tmux p10k config

# Optional: Install npm packages
cd npm && npm install -g && cd ..

# Optional: Install Claude config
cd claude && bash install.sh && cd ..
```

### Machine-Specific Configuration

The installer creates template files for machine-specific settings:
```bash
# Edit these files to add your local configurations
~/.gitconfig.local  # Personal git configuration (name, email, signing key)
~/.zshrc.local      # Shell aliases and functions
~/.zprofile.local   # Login shell environment variables
```

### Backup Your Configurations

```bash
# Quick backup (updates OS-specific Brewfile and apps inventory)
./backup.sh

# See what would be backed up without making changes
./backup.sh --dry-run
```

This backs up:
- Homebrew packages → `brew/Brewfile.basic`, `Brewfile.personal`, and `Brewfile.macos`
- Local zsh config → `zsh/.zshrc.local.example`
- macOS apps inventory → `apps/apps.yml` (macOS only)

## Uninstalling

To remove symlinks:
```bash
# Remove all configuration symlinks
stow -D */

# Or selectively
stow -D zsh git tmux p10k config

# Or individually
stow -D zsh
stow -D git
stow -D tmux
stow -D p10k
stow -D config
```

## Structure

- `apps/` - Application inventory and installation tracking (macOS)
- `brew/` - Homebrew packages (Brewfile.basic for work, Brewfile.personal for personal CLI, Brewfile.macos for GUI apps)
- `claude/` - Claude Code CLI configuration (MCP servers)
- `config/` - Miscellaneous .config subdirectories (bat, gh, htop, thefuck, nvim)
- `git/` - Git configuration with `.gitconfig.local.example` template
- `npm/` - Global NPM packages (cross-platform)
- `p10k/` - Powerlevel10k Zsh theme configuration
- `tmux/` - Tmux terminal multiplexer configuration
- `zsh/` - Zsh shell configuration with Oh My Zsh (cross-platform)

## Platform-Specific Features

### macOS
- **Homebrew packages**: All CLI tools, GUI applications, and Mac App Store apps
- **Application tracking**: Full inventory of installed applications
- **1Password integration**: SSH agent configuration

### Linux  
- **System packages**: Essential build tools via native package managers (apt, dnf, pacman)
- **CLI tools**: Same cross-platform tools as macOS via Homebrew (git, tmux, fzf, ripgrep, etc.)
- **Server-focused**: No GUI applications - optimized for CLI/server environments

### Cross-Platform
- **Shell configuration**: Zsh with machine-specific local configs
- **Git configuration**: Universal git settings with platform-specific SSH signing
- **Development tools**: Unified CLI toolchain via Homebrew (node, go, python, etc.)
- **NPM packages**: Global Node.js packages that work everywhere

## Scripts

### `install.sh` (85 lines)
Sets up everything from scratch:
- Installs Homebrew
- Installs packages from OS-specific Brewfile
- Links configurations with stow
- Runs special installers

### `backup.sh` (66 lines)
Backs up current machine state:
- Updates OS-specific Brewfile with installed packages
- Saves local configurations
- Updates apps inventory (macOS)

### `apps/check_apps.sh` (macOS only)
Tracks installed applications:
- Categorizes by source (Homebrew, App Store, manual)
- Shows installation status
- Generates `apps.yml` inventory

## Application Management (macOS only)

The `apps/` directory provides application inventory tracking for macOS:
```bash
# Check application installation status
./apps/check_apps.sh
```

This tracks installed applications from Homebrew Cask, Mac App Store, and manual installations. See the `apps/` directory for detailed inventory files.

## Why So Simple?

This used to be ~1,500 lines of bash with dynamic discovery, hooks, and complex backup logic. Now it's ~150 lines total. Why?

- **Explicit > Clever**: You have 10 directories. They rarely change. A simple list is clearer than pattern matching.
- **YAGNI**: You don't backup dotfiles daily. You don't need interactive mode, verbose flags, or pre/post hooks.
- **Maintainable**: When something breaks in 6 months, you can understand the entire script in 2 minutes.

The scripts do exactly what you need:
1. Install your tools and link your configs
2. Backup OS-specific Brewfile when you install new tools
3. Track macOS apps (if on macOS)

That's it. No framework, no magic, just straightforward bash that works.