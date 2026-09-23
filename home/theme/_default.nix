# Default theme, shared by every machine. A local override written by
# `theme-pick` / `wallpaper-pick` (see home/theme/stylix.nix) takes precedence;
# change this file only to move the default everywhere.
#
# Underscore prefix: import-tree must not pick this up as a Home Manager
# module. stylix.nix and the pickers import it by hand.
{
  # "scheme"    -> value is a name from pkgs.base16-schemes
  # "wallpaper" -> value is a file name under <repo>/wallpapers/
  kind = "scheme";
  value = "nord";
}
