# Initialize Homebrew if available
# Check common Homebrew installation locations
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    # macOS ARM (M1/M2)
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    # macOS Intel
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    # Linux system-wide installation
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    # Linux user installation
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

# Load machine-specific login configs
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local