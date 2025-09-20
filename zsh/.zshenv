# Lightweight, script-friendly zoxide
if command -v zoxide >/dev/null 2>&1; then
  # Provides the `z` command but skips slow hooks
  eval "$(zoxide init zsh --hook none)"
fi
