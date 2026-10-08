{ pkgs, ... }:
{
  home.packages = [ pkgs.ouch ];

  # Replaces the old `extract` shell function; ouch detects the format itself.
  programs.zsh.shellAliases = {
    extract = "ouch decompress";
    compress = "ouch compress";
  };
}
