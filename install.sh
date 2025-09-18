#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Simple OS detection
OS="unknown"
[[ "$OSTYPE" == "darwin"* ]] && OS="macos"
[[ "$OSTYPE" == "linux-gnu"* ]] && OS="linux"

# Detect Linux distribution if on Linux
DISTRO=""
if [[ "$OS" == "linux" ]]; then
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) DISTRO="debian" ;;
            fedora|rhel|centos) DISTRO="redhat" ;;
            arch|manjaro) DISTRO="arch" ;;
            *) DISTRO="unknown" ;;
        esac
    fi
fi

echo -e "${BLUE}🏠 Setting up dotfiles for $OS...${NC}"
[[ -n "$DISTRO" ]] && echo -e "${BLUE}  Linux distribution: $DISTRO${NC}"

# Check we have the right directory structure
if [[ ! -f "$DOTFILES_DIR/install.sh" || ! -d "$DOTFILES_DIR/brew" ]]; then
    echo -e "${RED}✗ Dotfiles directory structure is incorrect${NC}"
    exit 1
fi

# Change to dotfiles directory for relative operations
cd "$DOTFILES_DIR"

# Install essential system packages on Linux (required for Homebrew)
if [[ "$OS" == "linux" ]] && [[ -n "$DISTRO" ]]; then
    echo -e "${BLUE}Installing essential system packages...${NC}"
    case "$DISTRO" in
        debian)
            sudo apt-get update
            sudo apt-get install -y build-essential curl file git python3-pip
            ;;
        redhat)
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y curl file git python3-pip
            ;;
        arch)
            sudo pacman -S --noconfirm base-devel curl file git python-pip
            ;;
        *)
            echo -e "${YELLOW}⚠ Unknown Linux distribution. You may need to install build tools manually.${NC}"
            ;;
    esac
fi

# Install Homebrew first (needed for everything else)
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH based on OS
    if [[ "$OS" == "macos" ]]; then
        # Add to shell profiles for persistence
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
        # Try both Intel and Apple Silicon paths for current session
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
    else
        # Add to shell profiles for persistence on Linux
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
        # For current session
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null
    fi
    echo -e "${GREEN}✓ Homebrew installed and added to PATH${NC}"
fi

# Install packages from appropriate Brewfile based on OS
if [[ "$OS" == "macos" ]] && [[ -f "brew/Brewfile.macos" ]]; then
    echo "Installing Homebrew packages for macOS..."
    brew bundle --file=brew/Brewfile.macos || {
        echo -e "${YELLOW}⚠ Some packages may have failed to install${NC}"
    }
elif [[ "$OS" == "linux" ]] && [[ -f "brew/Brewfile.cli" ]]; then
    echo "Installing Homebrew packages for Linux/CLI..."
    brew bundle --file=brew/Brewfile.cli || {
        echo -e "${YELLOW}⚠ Some packages may have failed to install${NC}"
    }
else
    echo -e "${RED}✗ No appropriate Brewfile found for $OS${NC}"
    echo "  Expected: brew/Brewfile.macos (macOS) or brew/Brewfile.cli (Linux)"
    exit 1
fi

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}✓ Oh My Zsh installed${NC}"
fi

# Install Powerlevel10k theme
if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo -e "${GREEN}✓ Powerlevel10k theme installed${NC}"
fi

# Install Oh My Zsh plugins
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Check and backup existing dotfiles that might conflict with stow
echo "Checking for existing dotfiles..."
BACKUP_NEEDED=false
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# List of files that stow will try to create
DOTFILES_TO_CHECK=(
    ".zshrc" ".zprofile"           # from zsh/
    ".gitconfig" ".gitignore"      # from git/
    ".tmux.conf"                    # from tmux/
    ".p10k.zsh"                     # from p10k/
)

# Also check .config subdirectories
CONFIG_DIRS_TO_CHECK=(
    ".config/bat"
    ".config/gh"
    ".config/htop"
    ".config/nvim"
    ".config/thefuck"
)

# Check if any regular files exist and aren't already symlinks
for file in "${DOTFILES_TO_CHECK[@]}"; do
    if [[ -e "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
        BACKUP_NEEDED=true
        break
    fi
done

# Check if any .config directories exist and aren't symlinks
for dir in "${CONFIG_DIRS_TO_CHECK[@]}"; do
    if [[ -e "$HOME/$dir" ]] && [[ ! -L "$HOME/$dir" ]]; then
        BACKUP_NEEDED=true
        break
    fi
done

if [[ "$BACKUP_NEEDED" == true ]]; then
    echo -e "${YELLOW}⚠ Found existing dotfiles that would conflict with stow${NC}"
    echo "  Creating backup in: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # Backup regular dotfiles
    for file in "${DOTFILES_TO_CHECK[@]}"; do
        if [[ -e "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
            echo "  Backing up: $file"
            mv "$HOME/$file" "$BACKUP_DIR/"
        fi
    done

    # Backup .config directories
    mkdir -p "$BACKUP_DIR/.config"
    for dir in "${CONFIG_DIRS_TO_CHECK[@]}"; do
        if [[ -e "$HOME/$dir" ]] && [[ ! -L "$HOME/$dir" ]]; then
            dir_name=$(basename "$dir")
            echo "  Backing up: $dir"
            mv "$HOME/$dir" "$BACKUP_DIR/.config/$dir_name"
        fi
    done

    echo -e "${GREEN}✓ Existing dotfiles backed up and removed${NC}"
    echo "  Backup location: $BACKUP_DIR"
    echo ""
fi

# Stow configurations (explicit list - easy to see and modify)
echo "Linking configuration files..."
for dir in zsh git tmux p10k config; do
    if [[ -d "$dir" ]]; then
        echo "  Stowing $dir..."
        stow "$dir"
    fi
done

# Set up local git config if it doesn't exist
if [[ ! -f "$HOME/.gitconfig.local" ]] && [[ -f "git/.gitconfig.local.example" ]]; then
    echo -e "${BLUE}Setting up local git configuration...${NC}"
    cp git/.gitconfig.local.example "$HOME/.gitconfig.local"
    echo -e "${YELLOW}⚠ Please edit ~/.gitconfig.local with your personal git information:${NC}"
    echo "    - name: Your name for git commits"
    echo "    - email: Your email for git commits"
    echo "    - signingkey: Your SSH signing key (if using commit signing)"
fi

# Install NvChad if nvim config exists
if [[ -d "config/.config/nvim" ]]; then
    echo -e "${BLUE}Installing NvChad with custom configuration...${NC}"

    # Backup existing nvim config if it exists
    if [[ -d ~/.config/nvim ]]; then
        echo -e "${YELLOW}⚠ Backing up existing Neovim config to ~/.config/nvim.backup${NC}"
        rm -rf ~/.config/nvim.backup
        mv ~/.config/nvim ~/.config/nvim.backup
    fi

    # Clone fresh NvChad starter
    echo "Cloning NvChad starter..."
    git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1

    # Apply custom configurations (only the modified files)
    echo "Applying custom configurations..."
    cp "$DOTFILES_DIR/config/.config/nvim/chadrc.lua" ~/.config/nvim/lua/chadrc.lua
    cp "$DOTFILES_DIR/config/.config/nvim/mappings.lua" ~/.config/nvim/lua/mappings.lua
    cp "$DOTFILES_DIR/config/.config/nvim/conform.lua" ~/.config/nvim/lua/configs/conform.lua
    cp "$DOTFILES_DIR/config/.config/nvim/plugins.lua" ~/.config/nvim/lua/plugins/init.lua

    echo -e "${GREEN}✓ NvChad installed with custom configuration${NC}"
    echo -e "${YELLOW}  Run 'nvim' and wait for plugins to install on first launch${NC}"
fi

# Install TPM (Tmux Plugin Manager) if not already installed
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo -e "${BLUE}Installing Tmux Plugin Manager (TPM)...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo -e "${GREEN}✓ TPM installed${NC}"

    # Install tmux plugins automatically
    echo "Installing tmux plugins..."
    if "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null; then
        echo -e "${GREEN}✓ Tmux plugins installed${NC}"
    else
        echo -e "${YELLOW}⚠ Tmux plugins installation may have failed. Run prefix+I in tmux to install manually.${NC}"
    fi
else
    # Update existing plugins
    echo "Updating tmux plugins..."
    if "$HOME/.tmux/plugins/tpm/bin/update_plugins" all 2>/dev/null; then
        echo -e "${GREEN}✓ Tmux plugins updated${NC}"
    fi
fi

# Run special installers if they exist
if [[ -f "claude/install.sh" ]]; then
    echo "Installing Claude configuration..."
    (cd claude && bash install.sh)
fi

if [[ -f "npm/install.sh" ]]; then
    echo "Installing global npm packages..."
    bash npm/install.sh
fi

# Platform-specific: Check macOS applications
if [[ "$OS" == "macos" ]] && [[ -f "apps/check_apps.sh" ]]; then
    echo "Checking macOS applications..."
    (cd apps && bash check_apps.sh)
fi

# Create local config templates if they don't exist
if [[ ! -f ~/.zshrc.local ]]; then
    echo "# Machine-specific Zsh configuration" > ~/.zshrc.local
    echo -e "${YELLOW}⚠ Created ~/.zshrc.local for machine-specific settings${NC}"
fi

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
if [[ "$OS" == "macos" ]]; then
    echo "  2. Check missing apps: cd apps && ./check_apps.sh"
fi