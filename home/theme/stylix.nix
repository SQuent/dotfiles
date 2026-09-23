{
  pkgs,
  lib,
  config,
  ...
}:
# System-wide theming, colors.
#
# The theme is the repo default (./_default.nix) unless this machine has a
# local override in `dotfiles.theme.selectionFile`, written by theme-pick /
# wallpaper-pick. The override lives outside the repo, so switching theme never
# dirties the checkout; reading it needs --impure, which hm-switch already uses.
let
  cfg = config.dotfiles.theme;
  selection =
    if builtins.pathExists cfg.selectionFile then
      builtins.fromJSON (builtins.readFile cfg.selectionFile)
    else
      import ./_default.nix;
  # Checked here rather than in `assertions`: stylix reads the image while
  # evaluating its palette, before assertions ever run.
  wallpaper =
    let
      path = ../../wallpapers + "/${selection.value}";
    in
    lib.throwIfNot (builtins.pathExists path) ''
      ${cfg.selectionFile}: wallpaper "${selection.value}" is not in <repo>/wallpapers
      (deleted, or not committed?). Run `theme-pick --reset` to fall back to the default.
    '' path;
in
{
  options.dotfiles.theme.selectionFile = lib.mkOption {
    type = lib.types.str;
    default = "${config.xdg.stateHome}/dotfiles/theme.json";
    description = ''
      Per-machine theme override (JSON, same shape as ./_default.nix).
      Absent means the repo default applies.
    '';
  };

  config = {
    assertions = [
      {
        assertion = builtins.elem selection.kind [
          "scheme"
          "wallpaper"
        ];
        message = ''
          ${cfg.selectionFile}: kind must be "scheme" or "wallpaper", got "${selection.kind}".
        '';
      }
    ];

    stylix.enable = true;

    stylix.base16Scheme = lib.mkIf (
      selection.kind == "scheme"
    ) "${pkgs.base16-schemes}/share/themes/${selection.value}.yaml";

    stylix.image = lib.mkIf (selection.kind == "wallpaper") wallpaper;

    # autoEnable doesn't actually activate for GUI so not working.
    stylix.autoEnable = false;
    stylix.targets = {
      starship.enable = true;
      bat.enable = true;
      tmux.enable = true;
      fzf.enable = true;
      btop.enable = true;
      k9s.enable = true;
      yazi.enable = true;
      neovim.enable = true;
    };
  };
}
