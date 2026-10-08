{
  pkgs,
  lib,
  config,
  ...
}:
# `hm-switch`: rebuild + activate this flake via nh (package diff shown
# before activation). Used by the hm* aliases and the theme selectors.
{
  options.dotfiles.hmSwitch = lib.mkOption {
    type = lib.types.package;
    internal = true;
    description = ''
      The hm-switch wrapper
    '';
    default = pkgs.writeShellApplication {
      name = "hm-switch";
      runtimeInputs = [ config.programs.nh.package ];
      # -c: homeConfigurations are keyed by system, not user@host.
      text = ''
        exec nh home switch ${lib.escapeShellArg config.dotfiles.path} \
          -c ${lib.escapeShellArg pkgs.stdenv.hostPlatform.system} \
          --impure "$@"
      '';
    };
  };

  config.home.packages = [ config.dotfiles.hmSwitch ];
}
