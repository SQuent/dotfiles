{ lib, config, ... }:
let
  palette = config.lib.stylix.colors.withHashtag;
  # eza has no native palette indirection like starship. Resolve the
  # base16 slot names from theme.toml to real hex ourselves.
  resolveColor =
    path: value:
    if !(builtins.isString value) then
      value
    else if palette ? ${value} then
      palette.${value}
    else
      throw ''
        config/eza/theme.toml: ${lib.concatStringsSep "." path} = "${value}" is not a
        base16 slot (expected one of base00 .. base0F).
      '';
  resolveTheme = lib.mapAttrsRecursive resolveColor;
in
{
  home.sessionVariables.EZA_CONFIG_DIR = "${config.xdg.configHome}/eza";

  programs.eza = {
    enable = true;
    enableZshIntegration = true; # provides ls/ll/la/lt/lla
    icons = "auto";
    git = true;

    theme = lib.mkDefault (
      resolveTheme (builtins.fromTOML (builtins.readFile ../../config/eza/theme.toml))
    );
  };

  # Only the variants enableZshIntegration doesn't cover.
  programs.zsh.shellAliases = {
    ll = lib.mkForce "eza -laF --header";
    lt = lib.mkForce "eza -al --tree --header --level=2 --long";
    lm = "eza -lahr --color-scale -s=modified";
    lb = "eza -lahr --color-scale -s=size";
    tree = "eza --tree --level=3 --icons --git --group-directories-first";
    treea = "eza --tree --icons --git --group-directories-first";
  };
}
