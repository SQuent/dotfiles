#!/usr/bin/env zsh

# Syntax highlighting for commands
antigen bundle zsh-users/zsh-syntax-highlighting

# Extra zsh completions
antigen bundle zsh-users/zsh-completions

# Auto suggestions from history
antigen bundle zsh-users/zsh-autosuggestions

# Kubectl aliases
antigen bundle dbz/kube-aliases

# Display aliases you once defined and not use it
antigen bundle djui/alias-tips

# Tell antigen that you're done
antigen apply  