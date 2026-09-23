{ pkgs, ... }:
{
  home.packages = [ pkgs.trash-cli ];

  programs.zsh.shellAliases = {
    rm = "trash-put";
    tl = "trash-list";
    rmtrash = "trash-rm";
    tempty = "trash-empty";
    tr = "trash-restore";
  };
}
