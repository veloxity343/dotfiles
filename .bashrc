# ~/.bashrc

# ---------------------------------------------------------
# OS Detection
# ---------------------------------------------------------
OS_TYPE="$(uname)"

# ---------------------------------------------------------
# Color macros
# ---------------------------------------------------------

# Base ANSI colors (no shell-specific formatting)
_ANSI_RED='\e[0;31m'
_ANSI_GREEN='\e[0;32m'
_ANSI_YELLOW='\e[0;33m'
_ANSI_BLUE='\e[0;34m'
_ANSI_MAGENTA='\e[0;35m'
_ANSI_CYAN='\e[0;36m'
_ANSI_WHITE='\e[0;37m'
_ANSI_RESET='\e[0m'

# For echo/read (ANSI-safe)
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
WHITE=$'\e[0;37m'
RESET=$'\e[0m'

# For PS1 (prompt-safe)
RED_PS1="\[${_ANSI_RED}\]"
GREEN_PS1="\[${_ANSI_GREEN}\]"
YELLOW_PS1="\[${_ANSI_YELLOW}\]"
BLUE_PS1="\[${_ANSI_BLUE}\]"
MAGENTA_PS1="\[${_ANSI_MAGENTA}\]"
CYAN_PS1="\[${_ANSI_CYAN}\]"
WHITE_PS1="\[${_ANSI_WHITE}\]"
RESET_PS1="\[${_ANSI_RESET}\]"

#---------------------------------------------------------
# Aliases
#---------------------------------------------------------

alias ll='ls -lah'
alias la='ls -A'
alias cl='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -h'
alias ports='netstat -tulanp 2>/dev/null || lsof -iTCP -sTCP:LISTEN -n -P'

# Platform-specific aliases
if [ "$OS_TYPE" = "Darwin" ]; then
	alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
	alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
	alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
elif [ "$OS_TYPE" = "Linux" ]; then
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
	alias open='xdg-open'
fi

#---------------------------------------------------------
# Prompt
#---------------------------------------------------------

# Enhanced prompt with Git branch support
parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Show virtualenv if active
parse_virtualenv() {
	if [ -n "$VIRTUAL_ENV" ]; then
		echo " ($(basename "$VIRTUAL_ENV"))"
	fi
}

# Show user@host:path (venv) (branch) $
PS1="${GREEN_PS1}\u${RESET_PS1}@${CYAN_PS1}\h${RESET_PS1}:${BLUE_PS1}\w${MAGENTA_PS1}\$(parse_virtualenv)${YELLOW_PS1}\$(parse_git_branch)${RESET_PS1}\$ "

#---------------------------------------------------------
# Shell behaviour
#---------------------------------------------------------

# Enable colour support
export CLICOLOR=1

# Platform-specific color settings
if [ "$OS_TYPE" = "Darwin" ]; then
	export LSCOLORS=GxFxCxDxBxegedabagaced
else
	# Linux uses LS_COLORS
	if [ -x /usr/bin/dircolors ]; then
		eval "$(dircolors -b)"
	fi
	alias ls='ls --color=auto'
fi

# History usability
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
shopt -s checkwinsize

# Better tab completion
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

#---------------------------------------------------------
# Node.js environment
#---------------------------------------------------------

# Node Version Manager (nvm) - loads nvm command
export NVM_DIR="$HOME/.nvm"

# Try Homebrew nvm location first (macOS)
if [ "$OS_TYPE" = "Darwin" ] && [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
	source "/opt/homebrew/opt/nvm/nvm.sh"
	[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
# Then try standard nvm location
elif [ -s "$NVM_DIR/nvm.sh" ]; then
	source "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

# Add global npm packages to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# Configure npm to use custom global directory (optional - prevents sudo for global installs)
# Run once: mkdir ~/.npm-global && npm config set prefix '~/.npm-global'

# pnpm (alternative package manager)
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Bun (JavaScript runtime) - if installed
if [ -d "$HOME/.bun" ]; then
	export BUN_INSTALL="$HOME/.bun"
	export PATH="$BUN_INSTALL/bin:$PATH"
fi

#---------------------------------------------------------
# Python environment
#---------------------------------------------------------

# Python startup file for interactive sessions
export PYTHONSTARTUP="$HOME/.pythonrc"

# pyenv - Python version manager
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
	export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
	# pyenv-virtualenv (if installed)
	if command -v pyenv-virtualenv-init &>/dev/null; then
		eval "$(pyenv virtualenv-init -)"
	fi
fi

# Add user Python scripts to PATH
export PATH="$HOME/.local/bin:$PATH"

# pip settings
export PIP_REQUIRE_VIRTUALENV=false  # Set to true to force virtualenv usage
export PIP_DOWNLOAD_CACHE="$HOME/.pip/cache"

# Virtual environment indicator in prompt (if using venv/virtualenv)
export VIRTUAL_ENV_DISABLE_PROMPT=1  # We'll handle it ourselves

# Poetry (Python package manager)
if [ -d "$HOME/.poetry/bin" ]; then
	export PATH="$HOME/.poetry/bin:$PATH"
fi

# pipx (for installing Python CLI tools)
if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

#---------------------------------------------------------
# Git macros
#---------------------------------------------------------

git_timestamp() {
	date +"%Y-%m-%d %H:%M:%S"
}

root_dir() {
	command git rev-parse --show-toplevel 2>/dev/null
}

current_branch() {
	git symbolic-ref --short HEAD 2>/dev/null
}

gs() {
	git -C "$(root_dir)" status
}

ga() {
	local repo_root branch msg timestamp status_output

	repo_root=$(root_dir) || {
		echo "${RED}Not inside a Git repository.${RESET}" >&2
		return 1
	}

	branch=$(current_branch) || {
		echo "${RED}Failed to determine current branch.${RESET}" >&2
		return 1
	}

	timestamp="$(git_timestamp)"

	gs || {
		echo "${RED}Failed to run git status.${RESET}" >&2
		return 1
	}

	status_output=$(git -C "$repo_root" status --porcelain)
	if [ -z "$status_output" ]; then
		echo "${GREEN}Working tree clean. Nothing to commit.${RESET}"
		return 0
	fi

	# Show diff with color
	echo "${CYAN}Changes to be committed:${RESET}"
	git diff --color --stat

	read -p "${YELLOW}Continue? (y/n): ${RESET}" confirm
	if [[ "$confirm" != [Yy] ]]; then
		echo "${RED}Git commit aborted.${RESET}"
		return 1
	fi

	if [ $# -gt 0 ]; then
		commit_msg="$*"
	else
		read -ep "${MAGENTA}Commit message: ${RESET}" commit_msg
		if [ -z "$commit_msg" ]; then
			commit_msg="Generic auto-update"
		fi
	fi

	msg="$timestamp | $commit_msg"

	git add -A &&
	git commit -m "$msg" &&
	git push origin "$branch"
	echo "${GREEN}Pushed to '$branch' with commit: \"$msg\"${RESET}"
}

gl() {
	git log --graph --oneline --decorate --all
}

gu() {
	last_commit=$(git log -1 --pretty=format:"%h | %s")
	echo "Preparing to undo the last commit: "
	echo "${YELLOW}$last_commit${RESET}"
	read -p "Are you sure? (y/n): " confirm
	if [[ "$confirm" == [Yy] ]]; then
		git reset --soft HEAD~1
		echo "${GREEN}Last commit undone. Changes remain staged.${RESET}"
	else
		echo "${RED}Undo aborted.${RESET}"
	fi
}

gc() {
	# Git clone and cd into directory
	if [ $# -eq 0 ]; then
		echo "${RED}Usage: gc <git-url> [directory-name]${RESET}"
		return 1
	fi
	
	git clone "$1" "$2" && cd "$(basename "${2:-$1}" .git)" || return
}

#---------------------------------------------------------
# Custom functions
#---------------------------------------------------------

update() {
	if [ "$OS_TYPE" = "Darwin" ]; then
		echo "${BLUE}Updating Homebrew on macOS${RESET}"
		brew update && brew upgrade && brew cleanup
	elif [ "$OS_TYPE" = "Linux" ]; then
		# Detect package manager
		if command -v apt &>/dev/null; then
			echo "${BLUE}Updating APT packages on Linux${RESET}"
			sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
		elif command -v dnf &>/dev/null; then
			echo "${BLUE}Updating DNF packages on Linux${RESET}"
			sudo dnf upgrade -y && sudo dnf autoremove -y
		elif command -v pacman &>/dev/null; then
			echo "${BLUE}Updating Pacman packages on Linux${RESET}"
			sudo pacman -Syu --noconfirm
		else
			echo "${RED}No supported package manager found${RESET}"
			return 1
		fi
	else
		echo "${RED}Unsupported OS: $OS_TYPE${RESET}"
		return 1
	fi
}

up() {
	local d=""
	for ((i=0; i<${1:-1}; i++)); do d+="../"; done
	cd "$d" || return
}

big() {
	du -ah "${1:-.}" | sort -rh | head -n "${2:-10}"
}

trash() {
	local trash_dir
	
	if [ "$OS_TYPE" = "Darwin" ]; then
		trash_dir="$HOME/.Trash"
	else
		trash_dir="${XDG_DATA_HOME:-$HOME/.local/share}/Trash/files"
		mkdir -p "$trash_dir"
	fi
	
	if [ ! -d "$trash_dir" ]; then
		echo "${RED}Error:${RESET} Could not find or create trash directory"
		return 1
	fi
	
	if [ $# -eq 0 ]; then
		echo "${RED}Usage:${RESET} trash <file1> [file2] ..."
		return 1
	fi

	for item in "$@"; do
		if [ -e "$item" ]; then
			mv "$item" "$trash_dir/" && echo "${GREEN}Moved to trash:${RESET} $item"
		else
			echo "${RED}Not found:${RESET} $item"
		fi
	done
}

extract() {
	if [ $# -eq 0 ]; then
		echo "${RED}Usage:${RESET} extract <file>"
		return 1
	fi
	
	if [ -f "$1" ]; then
		case "$1" in
			*.tar.bz2)   tar xjf "$1"	;;
			*.tar.gz)	tar xzf "$1"	;;
			*.bz2)	   bunzip2 "$1"	;;
			*.rar)	   unrar x "$1"	;;
			*.gz)		gunzip "$1"	 ;;
			*.tar)	   tar xf "$1"	 ;;
			*.tbz2)	  tar xjf "$1"	;;
			*.tgz)	   tar xzf "$1"	;;
			*.zip)	   unzip "$1"	  ;;
			*.Z)		 uncompress "$1" ;;
			*.7z)		7z x "$1"	   ;;
			*.tar.xz)	tar xJf "$1"	;;
			*.tar.zst)   tar --zstd -xf "$1" ;;
			*)		   echo "${RED}Unsupported archive:${RESET} $1" ;;
		esac
	else
		echo "${RED}'$1' is not a valid file${RESET}"
	fi
}

mkcd() {
	mkdir -p "$1" && cd "$1" || return
}

bak() {
	for file in "$@"; do
		cp -r "$file" "${file}.bak.$(date +%Y%m%d-%H%M%S)"
	done
}

findtext() {
	if [ $# -lt 1 ]; then
		echo "${RED}Usage:${RESET} findtext <pattern> [path]"
		return 1
	fi
	grep -rnI "$1" "${2:-.}"
}

sysinfo() {
	echo "${CYAN}=== System Information ===${RESET}"
	echo "${YELLOW}OS:${RESET} $OS_TYPE $(uname -r)"
	echo "${YELLOW}Hostname:${RESET} $(hostname)"
	echo "${YELLOW}Uptime:${RESET} $(uptime | sed 's/.*up \([^,]*\), .*/\1/')"
	echo "${YELLOW}Memory:${RESET}"
	if [ "$OS_TYPE" = "Darwin" ]; then
		vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f MB\n", "$1:", $2 * $size / 1048576);'
	else
		free -h | grep "Mem:" | awk '{print "  Total: "$2" | Used: "$3" | Free: "$4}'
	fi
	echo "${YELLOW}Disk:${RESET}"
	df -h / | tail -1 | awk '{print "  Total: "$2" | Used: "$3" | Available: "$4" | Use%: "$5}'
	echo "${YELLOW}CPU:${RESET}"
	if [ "$OS_TYPE" = "Darwin" ]; then
		sysctl -n machdep.cpu.brand_string
	else
		grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
	fi
}

weather() {
	local location="${1:-}"
	curl -s "wttr.in/${location}?format=3"
}

#---------------------------------------------------------
# Enhanced navigation
#---------------------------------------------------------

# Quick bookmarks
export MARKPATH=$HOME/.marks
mkdir -p "$MARKPATH"

mark() {
	mkdir -p "$MARKPATH"
	ln -sf "$(pwd)" "$MARKPATH/$1"
	echo "${GREEN}Bookmarked:${RESET} $(pwd) as $1"
}

unmark() {
	rm -i "$MARKPATH/$1"
}

marks() {
	ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-20s -> %s\n", $1, $2}'
}

jump() {
	cd -P "$MARKPATH/$1" 2>/dev/null || echo "${RED}No such mark:${RESET} $1"
}

# Tab completion for jump
_jump_complete() {
	local marks
	marks=$(find "$MARKPATH" -type l -printf "%f\n" 2>/dev/null)
	COMPREPLY=($(compgen -W "$marks" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _jump_complete jump

#---------------------------------------------------------
# Node.js functions
#---------------------------------------------------------

# Quick npm run script selector
nr() {
	if [ ! -f package.json ]; then
		echo "${RED}No package.json found${RESET}"
		return 1
	fi
	
	local script
	script=$(node -pe "Object.keys(require('./package.json').scripts || {}).join('\n')" | fzf --height 40% --reverse --prompt "Select script: " 2>/dev/null)
	
	if [ -n "$script" ]; then
		echo "${GREEN}Running:${RESET} npm run $script"
		npm run "$script"
	else
		# Fallback if fzf not available
		echo "${YELLOW}Available scripts:${RESET}"
		node -pe "const p=require('./package.json'); Object.keys(p.scripts||{}).forEach(s=>console.log('  '+s))"
		read -p "Enter script name: " script
		[ -n "$script" ] && npm run "$script"
	fi
}

# Initialize new Node project with common setup
npminit() {
	npm init -y
	echo "node_modules/" >> .gitignore
	echo ".env" >> .gitignore
	echo "*.log" >> .gitignore
	git init
	echo "${GREEN}Node.js project initialized${RESET}"
}

# Clean node_modules and reinstall
npmclean() {
	echo "${YELLOW}Removing node_modules...${RESET}"
	rm -rf node_modules package-lock.json
	echo "${BLUE}Reinstalling packages...${RESET}"
	npm install
}

#---------------------------------------------------------
# Python functions
#---------------------------------------------------------

# Create and activate virtual environment
venv() {
	local venv_name="${1:-.venv}"
	
	if [ -d "$venv_name" ]; then
		echo "${YELLOW}Virtual environment '$venv_name' already exists${RESET}"
		source "$venv_name/bin/activate"
	else
		echo "${BLUE}Creating virtual environment: $venv_name${RESET}"
		python3 -m venv "$venv_name"
		source "$venv_name/bin/activate"
		pip install --upgrade pip
		echo "${GREEN}Virtual environment created and activated${RESET}"
	fi
}

# Deactivate virtual environment
voff() {
	if [ -n "$VIRTUAL_ENV" ]; then
		deactivate
		echo "${GREEN}Virtual environment deactivated${RESET}"
	else
		echo "${YELLOW}No active virtual environment${RESET}"
	fi
}

# Quick requirements.txt freeze
freeze() {
	if [ -n "$VIRTUAL_ENV" ]; then
		pip freeze > requirements.txt
		echo "${GREEN}Saved to requirements.txt${RESET}"
		echo "${CYAN}$(wc -l < requirements.txt) packages saved${RESET}"
	else
		echo "${RED}No active virtual environment${RESET}"
	fi
}

# Install from requirements.txt
pipi() {
	if [ -f requirements.txt ]; then
		pip install -r requirements.txt
	elif [ -f requirements-dev.txt ]; then
		pip install -r requirements-dev.txt
	else
		echo "${RED}No requirements file found${RESET}"
		return 1
	fi
}

# Python quick server (like Python's SimpleHTTPServer)
pyserve() {
	local port="${1:-8000}"
	echo "${CYAN}Starting Python HTTP server on port $port${RESET}"
	echo "${YELLOW}Access at: http://localhost:$port${RESET}"
	python3 -m http.server "$port"
}

# Initialize new Python project
pyinit() {
	local project_name="${1:-.}"
	
	if [ "$project_name" != "." ]; then
		mkdir -p "$project_name"
		cd "$project_name" || return
	fi
	
	python3 -m venv .venv
	source .venv/bin/activate
	
	cat > requirements.txt << EOF
# Add your dependencies here
EOF
	
	cat > .gitignore << EOF
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
ENV/
.env
*.log
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/
EOF
	
	git init
	echo "${GREEN}Python project initialized in $(pwd)${RESET}"
}

# List installed packages with versions
pipls() {
	pip list --format=columns
}

# Search PyPI for packages
pipsearch() {
	if [ $# -eq 0 ]; then
		echo "${RED}Usage:${RESET} pipsearch <package-name>"
		return 1
	fi
	
	pip index versions "$1" 2>/dev/null || {
		echo "${YELLOW}Searching PyPI...${RESET}"
		curl -s "https://pypi.org/pypi/$1/json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f\"Package: {data['info']['name']}\nVersion: {data['info']['version']}\nSummary: {data['info']['summary']}\")" 2>/dev/null || echo "${RED}Package not found${RESET}"
	}
}
