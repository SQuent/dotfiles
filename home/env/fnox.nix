{ lib, ... }:
{
  xdg.configFile."fnox/config.toml".source = ../../config/fnox/global.toml;
  home.file."git/gitlab/fnox.toml".source = ../../config/fnox/gitlab.toml;
  home.file."git/work/fnox.toml".source = ../../config/fnox/work.toml;
  home.file."git/nas/fnox.toml".source = ../../config/fnox/nas.toml;

  # Must run after bws: fnox reads BWS-exported env vars.
  dotfiles.zshInit.fnox = lib.hm.dag.entryAfter [ "bws" ] ''
    if command -v fnox >/dev/null 2>&1; then
      eval "$(fnox activate zsh)"
    fi
  '';
}
