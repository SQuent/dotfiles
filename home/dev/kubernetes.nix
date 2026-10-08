{ pkgs, ... }:
# kubectl itself comes from mise.
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
