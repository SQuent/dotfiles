{ lib, config, ... }:
let
  palette = config.lib.stylix.colors.withHashtag;
  # eza has no native palette indirection like starship — resolve the
  # base16 slot names from theme.toml to real hex ourselves. Anything that
  # isn't a string (a bool, a number) is a non-color eza setting and passes
  # through; an unknown *string* is a typo and must fail loudly rather than
  # end up in the generated theme as a literal colour name.
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
  # eza doesn't auto-detect $XDG_CONFIG_HOME/eza/theme.yml despite its docs; must be told explicitly.
  home.sessionVariables.EZA_CONFIG_DIR = "${config.xdg.configHome}/eza";

  programs.eza = {
    enable = true;
    enableZshIntegration = true; # provides ls/ll/la/lt/lla with basic flags
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
  };
}
