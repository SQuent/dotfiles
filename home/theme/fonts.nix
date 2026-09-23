{ lib, pkgs, ... }:
# The font itself is declared once here and fed to Stylix.
let
  monospace = pkgs.nerd-fonts.jetbrains-mono;
in
{
  stylix.fonts.monospace = {
    package = monospace;
    name = "JetBrainsMono Nerd Font Mono";
  };

  fonts.fontconfig.enable = true;

  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    "Library/Fonts/JetBrainsMonoNerdFont".source = "${monospace}/share/fonts";
  };
}
