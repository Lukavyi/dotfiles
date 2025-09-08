
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load machine-specific login configs
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local

