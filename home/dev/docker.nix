{ pkgs, config, ... }:
# CLI only, the daemon is provided by the host, not managed here.
{
  home.packages = with pkgs; [
    docker-client
    docker-compose
    lazydocker
  ];

  programs.docker-cli = {
    enable = true;
    configDir = "${config.xdg.configHome}/docker";
  };

  programs.zsh.shellAliases = {
    d = "docker";
    jupyter = "docker run -it -p 8888:8888 -v ${config.home.homeDirectory}/git/perso/notebook:/home/jovyan/work jupyter/notebook start.sh jupyter notebook --NotebookApp.token=''";
  };
}
