{ pkgs, ... }:
# kubectl itself comes from mise (config/mise/global.toml), not Nix.
# k9s goes through programs.k9s (not home.packages): Stylix's k9s target.
{
  home.packages = with pkgs; [
    kubectx
    kdash
    ctop
    helm-docs
  ];

  programs.k9s.enable = true;

  programs.zsh = {
    shellAliases.k = "kubectl";

    plugins = [
      {
        name = "kube-aliases";
        src = pkgs.fetchFromGitHub {
          owner = "dbz";
          repo = "kube-aliases";
          rev = "bfba5b625d613522947b1f526728cfba9430af63";
          hash = "sha256-+PCDWYgl/s+KbQ2pxbhlUv+WQB6njrJYFHhtxxzQgPM=";
        };
      }
    ];
  };
}
