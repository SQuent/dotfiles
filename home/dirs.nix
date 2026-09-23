{ lib, config, ... }:
# Directories nothing else creates as a side effect. Home Manager already
# makes any directory it writes a file into, so ~/git/{work,gitlab,nas} come
# for free from home/env/{fnox,mise}.nix — these two do not.
{
  home.activation.createUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG \
      ${lib.escapeShellArg "${config.home.homeDirectory}/scripts"} \
      ${lib.escapeShellArg "${config.home.homeDirectory}/git/github"}
  '';
}
