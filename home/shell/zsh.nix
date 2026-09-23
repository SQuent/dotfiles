{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dotfiles.zshInit = lib.mkOption {
    type = lib.hm.types.dagOf lib.types.lines;
    default = { };
    description = "zsh init-time shell snippets, topologically sorted into initContent.";
  };

  config = {
    dotfiles.zshInit = {
      nixDaemon = lib.hm.dag.entryAnywhere ''

        [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      '';

      bindkey = lib.hm.dag.entryAfter [ "nixDaemon" ] ''

        # Emacs key bindings (restores Ctrl+A, Ctrl+E, etc.)
        bindkey -e
      '';

      bws = lib.hm.dag.entryAfter [ "tmux" ] ''

        # Bootstrap secrets (BWS access token — local file, not managed by Nix)
        [[ -f ~/.bws ]] && source ~/.bws
      '';
    };

    programs.zsh = {
      enable = true;

      # XDG-relocate ~/.zshrc etc., matching history.path/completionInit below.
      dotDir = "${config.xdg.configHome}/zsh";

      enableCompletion = true;
      completionInit = ''
        fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
        autoload -U compinit && compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
      '';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        path = "${config.xdg.cacheHome}/zsh/history";
        size = 100000;
        save = 100000;
        share = true;
        extended = true;
        ignoreAllDups = true;
        saveNoDups = true;
        findNoDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
      };
      setOptions = [
        "HIST_VERIFY" # Preview history expansion before executing
        "HIST_NO_STORE" # Do not store 'history'/'fc' calls in history
        "HIST_REDUCE_BLANKS" # Strip superfluous blanks from commands
      ];

      antidote = {
        enable = true;
        plugins = [ "djui/alias-tips" ];
      };

      # Generic shell aliases
      shellAliases = {
        # Single-letter shortcuts
        a = "alias";
        c = "clear";
        e = "exit";
        f = "find";
        h = "history";
        i = "id";
        j = "jobs";
        m = "man";
        p = "pwd";
        s = "sudo";
        t = "touch";
        v = "vim";

        # Getting out of directories
        "c~" = "cd ~";
        "c." = "cd ..";
        "c.." = "cd ../../";
        "c..." = "cd ../../../";
        "c...." = "cd ../../../../";
        "c....." = "cd ../../../../";

        sz = "source ${config.programs.zsh.dotDir}/.zshrc";

        rsdate = ''sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"'';
        cl = "clear;ls";
        plz = "fc -l -1 | cut -d' ' -f2- | xargs sudo";

        serve = "python3 -m http.server";
        activate = "source ${config.xdg.dataHome}/myenv/bin/activate";

        dud = "du -d 1 -h";
        duall = "du -sh *";
        ff = "find . -type f -name";
        # No "fd" alias here on purpose: it used to shadow the real fd
        # binary (home/fd.nix) with this exact find-based lookup. `fd -t d
        # <pattern>` covers the same case natively.

        al = "alias | less";
        as = "alias | grep";
        ar = "unalias";

        meminfo = "free -m -l -t";
        memtop = "ps -eo pid,ppid,cmd,%mem --sort=-%mem | head";
        cputop = "ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head";
        cpuinfo = "lscpu";
        distro = "cat /etc/*-release";
        ports = "netstat -tulanp";

        myip = "curl icanhazip.com";
        cheat = "curl cheat.sh/";

        dotfiles = "${config.dotfiles.path}/install -v";
        dots = "dotfiles";
      };

      # Flattens the dotfiles.zshInit DAG in dependency order.
      initContent =
        let
          sorted = lib.hm.dag.topoSort config.dotfiles.zshInit;
        in
        lib.mkOrder 1000 (
          builtins.readFile ../../config/zsh/functions.zsh
          + (
            if sorted ? result then
              lib.concatMapStrings (entry: entry.data) sorted.result
            else
              abort ("Dependency cycle in dotfiles.zshInit: " + builtins.toJSON sorted)
          )
        );
    };
  };
}
