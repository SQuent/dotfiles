{ lib, config, ... }:
# Directories.
{
  home.activation.createUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG \
      ${lib.escapeShellArg "${config.home.homeDirectory}/scripts"} \
      ${lib.escapeShellArg "${config.home.homeDirectory}/git/github"}
  '';
}
