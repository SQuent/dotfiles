{ ... }:
{
  programs.btop.enable = true;

  programs.btop.settings.theme_background = false;

  # btop rewrites this file on exit; force Nix to always win.
  xdg.configFile."btop/btop.conf".force = true;

  programs.zsh.shellAliases = {
    htop = "btop";
    top = "btop";
  };
}
