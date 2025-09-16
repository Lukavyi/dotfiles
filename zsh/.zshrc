#!/bin/zsh
# Universal Zsh Configuration
# Works across Mac, NAS, and Docker containers

# ============================================================================
# Base Configuration
# ============================================================================
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'

# ============================================================================
# Powerlevel10k Instant Prompt
# ============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Terminal Configuration
# ============================================================================
# Function to detect and set the best available terminal
set_terminal() {
    # Check if we're inside tmux
    if [ -n "$TMUX" ]; then
        # Inside tmux, make sure we have proper 256 color support
        if [ "$TERM" = "xterm" ] || [ "$TERM" = "screen" ]; then
            export TERM=tmux-256color
        fi
        return
    fi

    # First, try to use ghostty if its terminfo is available
    # This is preferred for Ghostty terminal emulator
    if infocmp xterm-ghostty >/dev/null 2>&1; then
        export TERM=xterm-ghostty
    elif infocmp ghostty >/dev/null 2>&1; then
        export TERM=ghostty
    elif [ "$TERM" = "xterm" ] || [ "$TERM" = "linux" ]; then
        # Upgrade to 256 color if available
        if infocmp xterm-256color >/dev/null 2>&1; then
            export TERM=xterm-256color
        fi
    fi
}

# Call the function
set_terminal

# Ensure proper color support
export COLORTERM=truecolor
export CLICOLOR=1

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================
# Basic prompt configuration
export POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs status)
export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
export POWERLEVEL9K_STATUS_OK=false
export POWERLEVEL9K_STATUS_CROSS=true

# VCS (Git) Configuration - Modern color scheme
export POWERLEVEL9K_VCS_CLEAN_FOREGROUND='076'      # Bright green text
export POWERLEVEL9K_VCS_CLEAN_BACKGROUND='236'      # Dark gray background
export POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='220'   # Gold/yellow text
export POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='237'   # Slightly lighter gray
export POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='203'  # Salmon pink text
export POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='236'  # Dark gray background
export POWERLEVEL9K_VCS_DIRTY_FOREGROUND='214'      # Orange text
export POWERLEVEL9K_VCS_DIRTY_BACKGROUND='237'      # Slightly lighter gray

# Git status settings
export POWERLEVEL9K_SHOW_CHANGESET=true
export POWERLEVEL9K_CHANGESET_HASH_LENGTH=8

# Use gitstatusd only in tmux, regular git otherwise
if [[ -n "$TMUX" ]]; then
    # In tmux - use fast gitstatusd (shows counts)
    export POWERLEVEL9K_VCS_BACKEND=gitstatusd
    export POWERLEVEL9K_DISABLE_GITSTATUS=false
else
    # Outside tmux - use regular git (more reliable)
    export POWERLEVEL9K_VCS_BACKEND=git
    export POWERLEVEL9K_DISABLE_GITSTATUS=true
fi

# Icons for git status
export POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
export POWERLEVEL9K_VCS_UNSTAGED_ICON='✚'
export POWERLEVEL9K_VCS_STAGED_ICON='●'

# Show unpushed/unpulled commits
export POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
export POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
export POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM=99
export POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM=99
export POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname)

# ============================================================================
# Oh-My-Zsh Configuration
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins - combined from both versions
plugins=(git fzf web-search zsh-syntax-highlighting zsh-autosuggestions)

# ============================================================================
# PATH Configuration
# ============================================================================
# Basic paths
export PATH="$HOME/.local/bin:$PATH"

# pnpm (if installed)
if [[ -d "$HOME/Library/pnpm" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

# Homebrew OpenJDK (macOS ARM)
[[ -d "/opt/homebrew/opt/openjdk/bin" ]] && export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# LM Studio CLI (if installed)
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"

# Go
[[ -d "$HOME/go/bin" ]] && export PATH="$PATH:$HOME/go/bin"

# Container/workspace paths (if they exist)
[[ -d "/workspace/node_modules/.bin" ]] && export PATH="/workspace/node_modules/.bin:$PATH"

# ============================================================================
# Environment Setup
# ============================================================================
export EDITOR=nvim
export VISUAL=nvim
export SHELL=/bin/zsh

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# ============================================================================
# Tool Initialization (before Oh-My-Zsh)
# ============================================================================
# FZF key bindings and completion
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
elif command -v fzf &> /dev/null; then
    eval "$(fzf --zsh 2>/dev/null)" || true
fi

if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# Zoxide initialization
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# ============================================================================
# Source Oh-My-Zsh
# ============================================================================
source $ZSH/oh-my-zsh.sh

# ============================================================================
# Aliases
# ============================================================================

# Development shortcuts
alias c="claude"
alias oc="opencode"
alias cs="claude-squad"

# Editor aliases
alias vim="nvim"                                       # Use neovim instead of vim (from Synology-Homebrew)
alias vi="nvim"                                        # Use neovim instead of vi (from Synology-Homebrew)

# Modern CLI tool aliases
alias ll="eza -la --icons --octal-permissions --group-directories-first" # Better directory listing (from Synology-Homebrew)
alias ls="eza --color=always --group-directories-first --icons"          # Modern ls replacement (from Synology-Homebrew)
alias l="eza -l --icons --group-directories-first"     # Long format listing (from Synology-Homebrew)
alias la="eza -a --icons --group-directories-first"    # Show hidden files (from Synology-Homebrew)
alias tree="eza --tree --icons"                        # Tree view with icons (from Synology-Homebrew)
alias cat="bat --paging=never"
alias find="fd"                                        # User-friendly find (from Synology-Homebrew)
alias grep="rg"                                        # Fast ripgrep search (from Synology-Homebrew)
alias cd="z"                                           # Smart directory navigation (from Synology-Homebrew)
alias cdi="zi"                                         # Interactive directory selection (from Synology-Homebrew)

# Extended eza aliases
alias l="eza -bGF --header --git --color=always --group-directories-first --icons"
alias llm="eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons"
alias la="eza --long --all --group --group-directories-first"
alias lx="eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons"
alias lS="eza -1 --color=always --group-directories-first --icons"
alias lt="eza --tree --level=2 --color=always --group-directories-first --icons"
alias l.="eza -a | grep -E '^\.'"

# Git aliases
alias lg="lazygit"                                     # Terminal UI for git (from Synology-Homebrew)
alias gst="git status"
alias gd="git diff"
alias gdc="git diff --cached"

# Tmux aliases
alias tdev="tmux new-session -A -s dev"

# Utility aliases
alias man="tldr"                                       # Simplified man pages (from Synology-Homebrew)
alias help="tldr"                                      # Help command using tldr (from Synology-Homebrew)

# Reload shell configuration
alias reload="source ~/.zshrc"
alias reload-bash="source ~/.bashrc"

# Terminal info alias
alias terminfo='echo "TERM=$TERM"; echo "Colors: $(tput colors)"; echo "COLORTERM=$COLORTERM"'

# Claude CLI - detect correct path
if [[ -x "$HOME/.claude/local/claude" ]]; then
    alias claude="$HOME/.claude/local/claude"
elif [[ -x "/home/linuxbrew/.linuxbrew/lib/node_modules/@claude/cli/bin/claude" ]]; then
    alias claude="/home/linuxbrew/.linuxbrew/lib/node_modules/@claude/cli/bin/claude"
fi

# ============================================================================
# Platform-specific Configuration
# ============================================================================

# macOS: 1Password SSH Agent
if [[ "$OSTYPE" == "darwin"* ]]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# ============================================================================
# Additional Tool Initialization
# ============================================================================

# Perl local::lib (if available)
if command -v perl &> /dev/null && [[ -d "$HOME/perl5" ]]; then
    eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
fi

# thefuck command correction
command -v thefuck &> /dev/null && eval "$(thefuck --alias)"

# UV Python Package Manager
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# Source Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Test Functions (useful for terminal debugging)
# ============================================================================

# Terminal test functions
test256colors() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolour${i}\x1b[0m "
        if (( $i % 16 == 15 )); then echo; fi
    done
}

testtruecolors() {
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
}

# ============================================================================
# Machine-specific Configuration Loading
# ============================================================================

# Load machine-specific configurations
# .zshrc.local is for this specific machine (not tracked in git)
# .zshrc.$(hostname -s) can be used for configs specific to a hostname
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.zshrc.$(hostname -s) ]] && source ~/.zshrc.$(hostname -s)