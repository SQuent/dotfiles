{ ... }:
{
  programs.starship = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableIonIntegration = false;
    enableNushellIntegration = false;

    settings = builtins.fromTOML (builtins.readFile ../../config/starship/starship.toml);
  };
}
