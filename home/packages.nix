{ pkgs, lib, ... }:
# Catch-all packages with no associated aliases/env vars/config.
{
  home.packages =
    with pkgs;
    [
      #### Core  ####
      gnupg
      fontconfig
      wget
      jq
      yq
      ripgrep
      scc
      sd

      #### Dev tool ####
      libyaml

      #### CI/CD & Devops ####
      gitlab-ci-local

      #### Utilities ####
      curl
      pwgen
      fdupes
      gping
      httpie
      entr
      ttygif
      tldr
      librsvg
      jrnl

      #### Fun ####
      asciiquarium
      cmatrix
      figlet
      cbonsai
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-only (was `apt` in linux.conf.yaml)
      procps # provides `watch`, per migration guidance (no standalone `watch` pkg)
      file
      lsb-release
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      # Darwin-only (was macOS-only brew/cask in mac.conf.yaml)
      coreutils
      util-linux
      # font-jetbrains-mono-nerd-font cask -> home/fonts.nix
      # (pkgs.nerd-fonts.jetbrains-mono, installed on both platforms now)
    ];
}
