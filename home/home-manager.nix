{ config, pkgs, ... }:
# Aliases for driving this flake (build/activate/rollback/update), plus the
# scheduled cleanup of old generations and store paths.
#
# No runtime platform detection: this module is already evaluated *for* one
# system, so the flake reference can be baked in at build time.
let
  inherit (config.dotfiles) path;
  flakeRef = "${path}#${pkgs.stdenv.hostPlatform.system}";
in
{
  programs.zsh.shellAliases = {
    # Build + activate the new generation.
    hms = "hm-switch";
    # Preview what switch would do.
    hmsn = "hm-switch -n";
    # Build only (result left in ./result).
    hmb = "home-manager build --flake ${flakeRef} --impure";
    # Roll back to the previous generation.
    hmrb = "home-manager switch --rollback --impure";
    # List generations.
    hmg = "home-manager generations";
    # Show unread news since the last generation switch.
    hmn = "home-manager news --flake ${flakeRef} --impure";
    # Validate the flake (takes a positional flake-url, not --flake).
    hmc = "nix flake check ${path} --impure";
    # Update every flake input's lock.
    hmu = "nix flake update --flake ${path}";
    # Jump to the repo and open it in $EDITOR.
    hme = "cd ${path} && $EDITOR .";
    # Remove *all* old generations + unreachable store paths, right now (no
    # rollback left afterwards). The weekly job below is the gentler default.
    hmgc = "nix-collect-garbage -d";
  };

  # Weekly (launchd agent on macOS, systemd user timer on Linux): drop
  # generations older than 30 days.
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-30 days";
    store = {
      cleanup = true;
      options = "--delete-older-than 30d";
    };
  };
}
