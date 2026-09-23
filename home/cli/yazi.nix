{ ... }:
# programs.yazi.enable is required for Stylix's yazi target to have
# anything to inject into (it writes programs.yazi.theme).
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
}
