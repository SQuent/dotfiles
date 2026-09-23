{ lib, ... }:
{
  programs.mise.enable = true;
  programs.mise.enableZshIntegration = false; # custom-ordered below instead

  xdg.configFile."mise/config.toml".source = ../../config/mise/global.toml;
  home.file."git/gitlab/mise.toml".source = ../../config/mise/gitlab.toml;
  home.file."git/work/mise.toml".source = ../../config/mise/work.toml;
  home.file."git/nas/mise.toml".source = ../../config/mise/nas.toml;

  # Must run after fnox: mise.toml can reference fnox-exported env vars.
  dotfiles.zshInit.mise = lib.hm.dag.entryAfter [ "fnox" ] ''
    eval "$(mise activate zsh)"
  '';
}
