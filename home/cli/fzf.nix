{ lib, ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
    ];

    colors = {
      bg = lib.mkForce "-1";
      "bg+" = lib.mkForce "-1";
    };
    historyWidgetOptions = [
      "--no-sort"
      "--exact"
      "--prompt=History > "
    ];
  };
}
