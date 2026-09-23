{ lib, config, ... }:

let
  # Impure by design: resolved at activation time (needs --impure) so this
  # flake works unmodified for any user/machine.
  envOr =
    name: fallback:
    let
      value = builtins.getEnv name;
    in
    if value != "" then value else fallback;

  username = envOr "USER" (
    envOr "LOGNAME" (throw "dotfiles: neither $USER nor $LOGNAME is set (home-manager needs --impure)")
  );

  homeDirectory = envOr "HOME" (throw "dotfiles: $HOME is not set (home-manager needs --impure)");
in
{
  options.dotfiles.path = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/dotfiles";
    description = ''
      Absolute path to this checkout on the target machine. Single source of
      truth for every module that needs to point back at the repo
      (hm-switch, the hm* aliases, theme-pick/wallpaper-pick).
    '';
  };

  config = {
    home.username = username;
    home.homeDirectory = homeDirectory;

    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };
}
