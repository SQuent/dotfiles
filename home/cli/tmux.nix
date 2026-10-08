{
  config,
  lib,
  pkgs,
  ...
}:
let
  # macOS is known at build time; WSL vs plain Linux only at runtime.
  copyCommand =
    if pkgs.stdenv.isDarwin then
      "set -s copy-command 'pbcopy'"
    else
      ''
        if-shell "grep -qi microsoft /proc/version 2>/dev/null" \
          "set -s copy-command 'clip.exe'" \
          "set -s copy-command 'xclip -selection clipboard'"'';
in
{
  home.sessionVariables.TMUX_PLUGIN_MANAGER_PATH = "${config.xdg.dataHome}/tmux/plugins";

  # Not over SSH: the local terminal is usually already in tmux (nested
  # prefixes), and destroy-unattached would kill the session on disconnect.
  dotfiles.zshInit.tmux = lib.hm.dag.entryAfter [ "bindkey" ] ''
    if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" && -z "$SSH_CONNECTION" ]]; then
      tmux new-session
    fi
  '';

  programs.tmux = {
    enable = true;
    # Ensures panes use zsh even when $SHELL isn't set.
    shell = "${config.programs.zsh.package}/bin/zsh";
    extraConfig = ''
      set -g prefix C-b
      bind C-b send-prefix
      set -g mouse on

      # Destroy session when last client detaches (no persistent sessions)
      set -g destroy-unattached on

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Set sbonsai in screensaver 
      # set -g lock-command "cbonsai --live --infinite --life 50  --screensaver  --multiplier=7"
      # set -g lock-after-time 360

      # set vi-mode
      set-window-option -g mode-keys vi

      # Clipboard integration: copy-command is picked per platform (copyCommand), so
      # every copy-pipe-and-cancel binding here stays argument-free.
      set -g set-clipboard on
      ${copyCommand}
      bind-key -T copy-mode-vi v                 send-keys -X begin-selection
      bind-key -T copy-mode-vi y                 send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode-vi DoubleClick1Pane  send-keys -X select-word \; send-keys -X copy-pipe-and-cancel
      bind-key -T root         DoubleClick1Pane  copy-mode \; send-keys -X select-word \; send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode-vi TripleClick1Pane  send-keys -X select-line \; send-keys -X copy-pipe-and-cancel
      bind-key -T root         TripleClick1Pane  copy-mode \; send-keys -X select-line \; send-keys -X copy-pipe-and-cancel

      set -g status off

      bind v split-window -v -c "#{pane_current_path}"
      bind h split-window -h -c "#{pane_current_path}"
      unbind '"'
      unbind %
    '';
  };
}
