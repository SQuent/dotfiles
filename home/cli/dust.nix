{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.dust ];

  # `du` defaults to depth 1; `du N` shows N levels instead.
  dotfiles.zshInit.dust = lib.hm.dag.entryAnywhere ''

    du() {
      local depth=$1
      if [[ -z "$depth" ]]; then
        depth=1
      fi
      dust -r -d "$depth"
    }
  '';

  programs.zsh.shellAliases = {
    dua = "dust -r -n 9999";
  };
}
