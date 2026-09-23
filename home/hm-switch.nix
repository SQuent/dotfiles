{
  pkgs,
  lib,
  config,
  ...
}:
# `hm-switch`: rebuild + activate this flake. A real binary rather than just a
# shell alias, because theme-pick/wallpaper-pick exec it after writing their
# selection.
{
  options.dotfiles.hmSwitch = lib.mkOption {
    type = lib.types.package;
    internal = true;
    description = ''
      The hm-switch wrapper, exposed so other modules can put it on a
      generated script's PATH instead of relying on it being in the profile.
    '';
    default = pkgs.writeShellApplication {
      name = "hm-switch";
      runtimeInputs = [ config.programs.home-manager.package ];
      text = ''
        exec home-manager switch \
          --flake ${lib.escapeShellArg "${config.dotfiles.path}#${pkgs.stdenv.hostPlatform.system}"} \
          --impure "$@"
      '';
    };
  };

  config.home.packages = [ config.dotfiles.hmSwitch ];
}
