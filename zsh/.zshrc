export PATH="$PATH:$HOME/.local/bin"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

alias claude="~/.claude/local/claude"

# 1Password SSH Agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export PATH=$PATH:$HOME/go/bin

# Load machine-specific configurations
# .zshrc.local is for this specific machine (not tracked in git)
# .zshrc.$(hostname -s) can be used for configs specific to a hostname
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.zshrc.$(hostname -s) ]] && source ~/.zshrc.$(hostname -s)
