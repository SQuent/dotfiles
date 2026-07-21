# Directory for all-things ZSH config
utils_dir="${XDG_CONFIG_HOME}/utils"

export TMUX_PLUGIN_MANAGER_PATH="${XDG_DATA_HOME}/tmux/plugins"
export PIP_CONFIG_FILE="${XDG_CONFIG_HOME}/pip/pip.conf"
export PIP_LOG_FILE="${XDG_DATA_HOME}/pip/log"
export CURL_HOME="${XDG_CONFIG_HOME}/curl"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Detect OS
if [[ "$(uname)" == "Darwin" ]]; then
  OS="mac"
  BREW_PREFIX="/opt/homebrew"
  # Put GNU coreutils and util-linux binaries first so macOS uses them
  # instead of the BSD variants (enables: date -I, setsid, flock, ...)
  export PATH="${BREW_PREFIX}/opt/coreutils/libexec/gnubin:${BREW_PREFIX}/opt/util-linux/bin:${PATH}"
else
  OS="linux"
  BREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

eval "$(${BREW_PREFIX}/bin/brew shellenv)"

# Set default applications
export EDITOR="vim"

export PATH="$PATH:$HOME/.local/bin"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Auto-start tmux: attach to existing session or create new one
if command_exists tmux && [[ -z "$TMUX" ]]; then
  tmux new-session
fi

# Set color breeze to exa (better ls)
export EZA_COLORS="ur=34:uw=35:ux=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"

# X11 display — Linux only
[[ "$OS" == "linux" ]] && export DISPLAY=:0

    # Import config files
source ${ZDOTDIR}/aliases.zsh
source ${ZDOTDIR}/history.zsh
source ${ZDOTDIR}/functions.zsh
    
  # Setup Antidote and load plugins
  export ANTIDOTE_HOME="${XDG_CACHE_HOME}/zsh/antidote"
  antidote_bin="${BREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh"
  if [[ -f "$antidote_bin" ]]; then
    source "$antidote_bin"
    # Initialize completion system before loading plugins (required for compdef)
    autoload -Uz compinit && compinit
    antidote load
  else
    echo "Antidote is not installed."
  fi

# Bootstrap secrets
[[ -f ~/.bws ]] && source ~/.bws

# Check if starship is installed, then initialize starship prompt
if command_exists starship; then
  eval "$(starship init zsh)"
else
  echo "Starship is not installed."
fi

# mise — runtime version manager (reads .tool-versions and mise.toml)
# Handles auto-install and cd hook natively
if command_exists fnox; then
  eval "$(fnox activate zsh)"
fi

if command_exists mise; then
  eval "$(mise activate zsh)"
else
  echo "mise is not installed."
fi

# Emacs key bindings (restores Ctrl+A, Ctrl+E, etc.)
bindkey -e

# fzf — Ctrl+R (history), Ctrl+T (files), Alt+C (directories)
# Requires fzf >= 0.48 — always satisfied via brew (macOS and Linux)
if command_exists fzf; then
  eval "$(fzf --zsh)"
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline'
  export FZF_CTRL_R_OPTS='--no-sort --exact --prompt="History > "'
fi