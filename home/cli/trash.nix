{ pkgs, ... }:
{
  home.packages = [ pkgs.gtrash ];

  programs.zsh.shellAliases = {
    rm = "gtrash put"; # `rm -rf dir` still works
    tl = "gtrash find";
    trs = "gtrash restore";
    rmtrash = "gtrash find --rm";
    tempty = "gtrash find --rm"; # whole trash, asks for confirmation
    ts = "gtrash summary";
  };
}
