# Lightweight, script-friendly zoxide for non-interactive termianl, like in Claude Code
if command -v zoxide >/dev/null 2>&1; then
  # Provides the `z` command but skips slow hooks
  eval "$(zoxide init zsh --hook none)"
fi

# Load machine-specific environment configurations
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
