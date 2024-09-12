zsh_dir=${XDG_CONFIG_HOME:-$HOME/.config/zsh}
antigen_dir="${XDG_CACHE_HOME}/zsh/antigen"
antigen_git="https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh"

antigen_bin="${antigen_dir}/antigen.zsh"

# Import angigen if present, or prompt to install if missing
if [[ -f $antigen_bin ]]; then
  source $antigen_bin
else
  echo " install Antigen"
  echo
  mkdir -p $antigen_dir
  curl -L $antigen_git > $antigen_bin
  source $antigen_bin
fi
