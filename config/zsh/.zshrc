# Directory for all-things ZSH config
utils_dir="${XDG_CONFIG_HOME}/utils"

export TMUX_PLUGIN_MANAGER_PATH="${XDG_DATA_HOME}/tmux/plugins"
export PIP_CONFIG_FILE="${XDG_CONFIG_HOME}/pip/pip.conf"
export PIP_LOG_FILE="${XDG_DATA_HOME}/pip/log"
export CURL_HOME="${XDG_CONFIG_HOME}/curl"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export ADOTDIR="${XDG_CACHE_HOME}/zsh/antigen"

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
  
  # Setup Antigen, and import plugins
source ${ZDOTDIR}/setup-antigen.zsh
source ${ZDOTDIR}/import-plugins.zsh

if [ -f ~/.secret ]; then
    source ~/.secret
fi

# Check if starship is installed, then initialize starship prompt
if command_exists starship; then
  eval "$(starship init zsh)"
else
  echo "Starship is not installed."
fi

# Check if thefuck is installed, then set up the alias
if command_exists thefuck; then
  eval "$(thefuck --alias)"
else
  echo "Thefuck is not installed."
fi

# Check if direnv is installed, then hook direnv
if command_exists direnv; then
  eval "$(direnv hook zsh)"
else
  echo "Direnv is not installed."
fi

# Check if asdf is installed, then initialize asdf
if command_exists asdf; then
  asdf_init="${BREW_PREFIX}/opt/asdf/libexec/asdf.sh"
  [[ -f "${asdf_init}" ]] && source "${asdf_init}"
  
  # Function to auto-install missing versions from .tool-versions
  asdf_auto_install() {
    if [[ -f .tool-versions ]]; then
      asdf install 2>/dev/null || true
    fi
  }
  
  # Run on shell startup
  asdf_auto_install
  
  # Hook to run when changing directory
  autoload -U add-zsh-hook
  add-zsh-hook chpwd asdf_auto_install
else
  echo "Asdf is not installed."
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