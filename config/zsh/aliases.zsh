######################################################################
#                                                                    # 
# General aliases                                                    #
#                                                                    #
######################################################################


command_exists () {
  hash "$1" 2> /dev/null
}

alias_not_used () {
  ! alias "$1" >/dev/null && ! hash "$1" 2> /dev/null
}

# Single-letter aliases, for frequently used basics, only if not already set
if alias_not_used a; then; alias a='alias'; fi
if alias_not_used c; then; alias c='clear'; fi
if alias_not_used d; then; alias d='docker'; fi
if alias_not_used e; then; alias e='exit'; fi
if alias_not_used f; then; alias f='find'; fi
if alias_not_used h; then; alias h='history'; fi
if alias_not_used i; then; alias i='id'; fi
if alias_not_used j; then; alias j='jobs'; fi
if alias_not_used k; then; alias k='kubectl'; fi
if alias_not_used l; then; alias l='ls'; fi
if alias_not_used m; then; alias m='man'; fi
if alias_not_used p; then; alias p='pwd'; fi
if alias_not_used s; then; alias s='sudo'; fi
if alias_not_used t; then; alias t='touch'; fi
if alias_not_used v; then; alias v='vim'; fi


# Getting outa directories
alias c~='cd ~'
alias c.='cd ..'
alias c..='cd ../../'
alias c...='cd ../../../'
alias c....='cd ../../../../'
alias c.....='cd ../../../../'


# If exa installed, then use exa for some ls commands
if command_exists eza ; then
  alias l='eza -aF --icons' # Quick ls
  alias la='eza -aF --icons' # List all
  alias ll='eza -laF --icons --header' # Show details
  alias lm='eza -lahr --color-scale --icons -s=modified' # Recent
  alias lb='eza -lahr --color-scale --icons -s=size' # Largest / size
  alias lt='eza -al --tree --header --icons --level=2 --long'
else
  alias la='ls -A' # List all files/ includes hidden
  alias ll='ls -lAFh' # List all files, with full details
  alias lb='ls -lhSA' # List all files sorted by biggest
  alias lm='ls -tA -1' # List files sorted by last modified
fi

# All days
if command_exists bat ; then
  # (-pp for no pagination)
  alias cat="bat -pp"
fi
alias vi="vim"
if command_exists nvim ; then
alias vim="nvim"
alias vdiff='nvim -d'
fi
alias sz="source ${XDG_CONFIG_HOME}/.zshrc"

# alias gcloud="docker run -it -v ~/.config/kube:/root/.kube  -v ~/.config/.kube:/root/.config/gcloud --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:latest gcloud"

# Manage trash
if command_exists trash-put ; then 
  alias rm=trash-put  # – Delete specified files or directories.
  alias tl=trash-list #– Displays the contents of the trash. 
  alias rmtrash=trash-rm # – Delete individual files or directories from the trash. 
  alias tempty=trash-empty #– Delete all files and directories from trash. 
  alias tr=trash-restore #– Restore the specified file or directory. 
fi

# Resotre Date
alias rsdate="sudo date -s \"\$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z\""
alias cls='clear;ls' # Clear and ls
alias plz="fc -l -1 | cut -d' ' -f2- | xargs sudo" # Re-run last cmd as root
alias wip='git add .; git commit -m "wip"; git push'
if command_exists docker ; then
alias jupyter="docker run -it -p 8888:8888 -v ${HOME}/git/perso/notebook:/home/jovyan/work jupyter/notebook start.sh jupyter notebook --NotebookApp.token=''"
fi
if command_exists neofetch ; then
alias neofetch="neofetch --ascii_colors 6 --colors 4 4 4 4 4 8"
fi

# Python
alias serve='python3 -m http.server'
alias activate=source  ${XDG_DATA_HOME}/myenv/bin/activate

# Finding files and directories
alias dud='du -d 1 -h' # List sizes of files within directory
alias duall='du -sh *' # List total size of current directory
alias ff='find . -type f -name' # Find a file by name within current directory
(( $+commands[fd] )) || alias fd='find . -type d -name' # Find direcroy by name

# Command line history
alias h-search='fc -El 0 | grep' # Searchses for a word in terminal history
alias top-history='history 0 | awk '{print $2}' | sort | uniq -c | sort -n -r | head' 
alias hg='history | grep' # Rip grep search recent history

# Find + manage aliases
alias al='alias | less' # List all aliases
alias as='alias | grep' # Search aliases
alias ar='unalias' # Remove given alias

# System Monitoring
alias meminfo='free -m -l -t' # Show free and used memory
alias memhog='ps -eo pid,ppid,cmd,%mem --sort=-%mem | head' # Processes consuming most mem
alias cpuhog='ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head' # Processes consuming most cpu
alias cpuinfo='lscpu' # Show CPU Info
alias distro='cat /etc/*-release' # Show OS info
alias ports='netstat -tulanp' # Show open ports

# External Services
alias myip='curl icanhazip.com'
# alias weather='curl wttr.in'
# alias weather-short='curl "wttr.in?format=3"'
alias cheat='curl cheat.sh/'
# alias joke='curl https://icanhazdadjoke.com'

# Alias for install script
alias dotfiles="${DOTFILES_DIR:-$HOME/dotfiles}/install -v"
alias dots="dotfiles"


######################################################################
#                                                                    # 
# ZSH aliases and helper functions for working with Git              #
#                                                                    #
######################################################################
# Basics
alias g="git"
alias gs="git status" # List changed files  
alias ga="git add" # Add <files> to the next commit
alias gaa="git add ." # Add all changed files
alias grm="git rm" # Remove <file>
alias gc="git commit" # Commit staged files, needs -m ""
alias gps="git push" # Push local commits to <origin> <branch>
alias gpl="git pull" # Pull changes with <origin> <branch>
alias gf="git fetch" # Download branch changes, without modifying files
alias gmultipull="find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;" 

# Merging and Rebasing
alias grb="git rebase" # Rebase the current HEAD into <branch>
alias grba="git rebase --abort" # Cancel current rebase sesh
alias grbc="git rebase --continue" # Continue onto next diff
alias gm="git merge" # Merge <branch> into your current HEAD

# Repo setup
alias gi="git init" # Initiialize a new empty local repo
alias gcl="git clone" # Downloads repo from <url>

# Branching
alias gch="git checkout" # Switch the HEAD to <branch>
alias gb="git branch" # Create a new <branch> from HEAD
alias gd="git diff" # Show all changes to untracked files
alias gtree="git log --graph --oneline --decorate --abbrev-commit" # Show branch tree
alias gl='git log'

# Pre commit
alias pc='pre-commit run --all-files'

######################################################################
#                                                                    # 
# ZSH aliases for working with cloud (tf, tg, aws)                   #
#                                                                    #
######################################################################

# AWS
alias awslogin='aws configure list-profiles | fzf --height=20 | xargs -I {} sh -c "\
aws sso login --profile {}; \
aws eks update-kubeconfig --name=main --profile {} && \
current_context=$(kubectl config current-context); \
kubectl config rename-context \$current_context {}"'

# Terragrunt
alias tg='terragrunt'
alias tgi='terragrunt init'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'
alias tgd='terragrunt destroy'
alias cctg='find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;'

# Terraform
alias tf='terraform'
alias tfi='terraform init --upgrade'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tffmt='terraform destroy'

# Kubernetes
alias reloadkc='export KUBECONFIG=~/.kube/config:$(find ~/.kube/kubeconfig -type f | tr "\n" ":") && kubectl config view --flatten > ~/.kube/config && export KUBECONFIG='
