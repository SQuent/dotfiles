{ pkgs, ... }:
{
  home.packages = [ pkgs.duf ];

  programs.zsh.shellAliases.df = "duf";
}
