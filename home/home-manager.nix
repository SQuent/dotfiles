{ config, pkgs, ... }:
# Aliases for driving this flake (build/activate/rollback/update) through nh,
# plus scheduled cleanup of old generations.
let
  inherit (config.dotfiles) path;
  system = pkgs.stdenv.hostPlatform.system;
  flakeRef = "${path}#${system}";
in
{
  programs.nh = {
    enable = true;
    homeFlake = path;

    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  programs.zsh.shellAliases = {
    # Build + activate the new generation (shows the package diff first).
    hms = "hm-switch";
    # Same, but asks for confirmation after the diff.
    hmsa = "hm-switch --ask";
    # Preview what switch would do.
    hmsn = "hm-switch --dry";
    # Update every flake input's lock, then build + activate.
    hmsu = "hm-switch --update";
    # Build only.
    hmb = "nh home build ${path} -c ${system} --impure";
    # Roll back to the previous generation (nh has no home rollback).
    hmrb = "home-manager switch --rollback --impure";
    # List generations.
    hmg = "home-manager generations";
    # Show unread news since the last generation switch.
    hmn = "home-manager news --flake ${flakeRef} --impure";
    # Validate the flake (takes a positional flake-url, not --flake).
    hmc = "nix flake check ${path} --impure";
    # Update every flake input's lock, without activating.
    hmu = "nix flake update --flake ${path}";
    # Jump to the repo and open it in $EDITOR.
    hme = "cd ${path} && $EDITOR .";
    # Remove *all* old generations + unreachable store paths, right now (no
    # rollback left afterwards). The weekly job above is the gentler default.
    hmgc = "nh clean user";
  };
}
