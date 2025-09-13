# Dotfiles

Personal dotfiles managed with GNU Stow.

## ⚠️ Personal Repository

**This repository is for personal use only and contains sensitive information:**
- Personal name, email, and SSH signing keys in git configuration
- Machine-specific paths and credentials
- Not intended for sharing, forking, or use as a template

If you're looking to create your own dotfiles repository, please start from scratch or use a dedicated dotfiles template that doesn't include personal information.

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
- Detect your OS (macOS or Linux)
- Install required dependencies (Homebrew, Stow, etc.)
- Install packages appropriate for your platform
- Set up configuration symlinks
- Create machine-specific config templates

### Manual Installation

If you prefer manual control:

#### Prerequisites
- **macOS**: Homebrew and Stow (`brew install stow`)
- **Linux**: Stow and your distribution's package manager

#### macOS Manual Setup
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew packages and Mac App Store apps
brew bundle --file=brew/Brewfile

# Install global npm packages
cd npm && npm install -g && cd ..

# Install configurations
stow zsh git
```

#### Linux Manual Setup
```bash
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
```

### Machine-Specific Configuration

The installer creates template files for machine-specific settings:
```bash
# Edit these files to add your local configurations
~/.zshrc.local      # Shell aliases and functions
~/.zprofile.local   # Login shell environment variables
```

### Using Stow Manually

#### All configurations at once:
```bash
# Safe bulk operation (automatically ignores non-config directories)
stow */

# Or selectively specify directories
stow -v zsh git
```

#### Individual configurations:
```bash
# Shell configuration
stow -v zsh

# Git configuration
stow -v git
```

**Note**: The repository includes a `.stow-local-ignore` file that prevents accidental stowing of package management directories (`apps/`, `brew/`, `claude/`, `npm/`), so bulk operations are safe.

## Uninstalling

To remove symlinks:
```bash
# Remove all configuration symlinks
stow -D */

# Or selectively
stow -D zsh git

# Or individually
stow -D zsh
stow -D git
```

## Structure

- `apps/` - Application inventory and installation tracking (macOS)
- `brew/` - Homebrew packages (Brewfile) - cross-platform CLI tools, macOS GUI apps
- `claude/` - Claude Code CLI configuration (MCP servers)
- `git/` - Git configuration (cross-platform)
- `npm/` - Global NPM packages (cross-platform)
- `zsh/` - Zsh shell configuration (cross-platform)

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

## Updating Brewfile

To update the Brewfile with currently installed packages (works on both macOS and Linux):
```bash
brew bundle dump --file=brew/Brewfile --force
```

## Application Management (macOS only)

The `apps/` directory provides application inventory tracking for macOS:
```bash
# Check application installation status
./apps/check_apps.sh
```

This tracks installed applications from Homebrew Cask, Mac App Store, and manual installations. See the `apps/` directory for detailed inventory files.

## Managing Dotfiles Across Multiple Machines

### Backup Current Machine's Configs
Before applying dotfiles from the repo, capture your current machine's setup:

```bash
# Create a backup branch for this machine
git checkout -b $(hostname)-$(date +%Y%m%d)

# Dump current configs
brew bundle dump --file=brew/Brewfile.$(hostname) --force
npm list -g --depth=0 > npm/global-packages.$(hostname).txt

# macOS only - backup app inventory
if [[ "$OSTYPE" == "darwin"* ]]; then
    ls /Applications | sort > apps/installed_apps.$(hostname).txt
fi

# Compare with main configs
diff brew/Brewfile brew/Brewfile.$(hostname)
```

### Merging Configs from Different Machines

**1. For Brewfile:**
```bash
# Combine unique packages from multiple machines
cat brew/Brewfile.* | grep "^brew " | sort -u > brew/Brewfile.merged
cat brew/Brewfile.* | grep "^cask " | sort -u >> brew/Brewfile.merged
cat brew/Brewfile.* | grep "^mas " | sort -u >> brew/Brewfile.merged
```

**2. For shell configs with machine-specific settings:**
```bash
# In .zshrc, use conditionals for machine-specific configs
if [[ $(hostname) == "work-mac" ]]; then
    export WORK_VAR="value"
elif [[ $(hostname) == "personal-mac" ]]; then
    export HOME_VAR="value"
fi
```

**3. Keep machine-specific branches:**
```bash
git checkout -b $(hostname)
# Make machine-specific changes
git commit -m "Config for $(hostname)"
# Cherry-pick universal changes to main
git checkout main
git cherry-pick <commit-hash>
```