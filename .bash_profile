# ~/.bash_profile

# Detect OS
OS_TYPE="$(uname)"

# Platform-specific PATH
if [ "$OS_TYPE" = "Darwin" ]; then
	export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [ "$OS_TYPE" = "Linux" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

if [ -f "$HOME/.bashrc" ]; then
	source "$HOME/.bashrc"
fi
