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

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Set default applications
export EDITOR="vim"

export PATH="$PATH:/home/${USER}/.local/bin"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set color breeze to exa (better ls)
export EZA_COLORS="ur=34:uw=35:ux=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36"

export DISPLAY=:0

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
  # Resolve asdf init script — path differs between Linuxbrew and macOS Homebrew
  if [[ -f /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh ]]; then
    source /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh
  elif [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
    source /opt/homebrew/opt/asdf/libexec/asdf.sh
  elif [[ -f /usr/local/opt/asdf/libexec/asdf.sh ]]; then
    source /usr/local/opt/asdf/libexec/asdf.sh
  fi
  
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

# to restore binkey ctrl a e r 
bindkey -e

if command_exists tmux; then
  tmux source-file ${XDG_CONFIG_HOME}/.tmux.conf
else
  echo "Tmux is not installed."
fi


bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward