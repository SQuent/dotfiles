#!/usr/bin/env zsh

# History file — ensure directory exists
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

# Sizes — keep equal to avoid silent truncation
HISTSIZE=100000
SAVEHIST=100000

# Options
setopt extended_history       # Record timestamp of command in $HISTFILE
setopt hist_expire_dups_first  # Delete duplicates first when HISTFILE is full
setopt hist_ignore_all_dups    # Remove older duplicate entries anywhere in history
setopt hist_save_no_dups       # Do not write duplicate entries to the history file
setopt hist_find_no_dups      # Skip duplicates when searching history
setopt hist_ignore_space      # Skip commands prefixed with a space
setopt hist_reduce_blanks     # Strip superfluous blanks from commands
setopt hist_verify            # Preview history expansion before executing
setopt hist_no_store          # Do not store 'history' / 'fc' calls in history
setopt share_history          # Share history across all sessions