# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git web-search zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# =============================================================================
# PATH Configuration
# =============================================================================

# Basic paths
export PATH="$PATH:$HOME/.local/bin"

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

# =============================================================================
# Terminal Configuration
# =============================================================================

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

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# =============================================================================
# Aliases
# =============================================================================

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.

# Editor aliases
alias vim="nvim"
# alias nvim="NVIM_APPNAME=\"nvim-kickstart\" nvim"  # Disabled for NvChad

# File listing aliases (using eza)
alias cat="bat --paging=never"
alias ls="eza --color=always --group-directories-first --icons"
alias ll="eza -la --icons --octal-permissions --group-directories-first --icons"
alias l="eza -bGF --header --git --color=always --group-directories-first --icons"
alias llm="eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons"
alias la="eza --long --all --group --group-directories-first"
alias lx="eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons"
alias lS="eza -1 --color=always --group-directories-first --icons"
alias lt="eza --tree --level=2 --color=always --group-directories-first --icons"
alias l.="eza -a | grep -E '^\.'"

# Git and development
alias lg="lazygit"
alias tdev="tmux new-session -A -s dev"

# Claude CLI
alias claude="~/.claude/local/claude"

# Navigation aliases
alias cd="z"

# =============================================================================
# Platform-specific Configuration
# =============================================================================

# macOS: 1Password SSH Agent
if [[ "$OSTYPE" == "darwin"* ]]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# =============================================================================
# Tool Initialization
# =============================================================================

# Perl local::lib (if available)
if command -v perl &> /dev/null && [[ -d "$HOME/perl5" ]]; then
    eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
fi

# fzf key bindings and fuzzy completion
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi

# thefuck command correction
if command -v thefuck &> /dev/null; then
    eval "$(thefuck --alias)"
fi

# zoxide for smart cd
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Source Powerlevel10k if installed
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# Test Functions (useful for terminal debugging)
# =============================================================================

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

# Aliases for terminal info
alias terminfo='echo "TERM=$TERM"; echo "Colors: $(tput colors)"; echo "COLORTERM=$COLORTERM"'

# =============================================================================
# Machine-specific Configuration Loading
# =============================================================================

# Load machine-specific configurations
# .zshrc.local is for this specific machine (not tracked in git)
# .zshrc.$(hostname -s) can be used for configs specific to a hostname
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.zshrc.$(hostname -s) ]] && source ~/.zshrc.$(hostname -s)