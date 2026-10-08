{ pkgs, ... }:
{
  home.packages = [ pkgs.fastfetch ];

  programs.zsh.shellAliases = {
    meminfo = "fastfetch -s memory -l none";
    cpuinfo = "fastfetch -s cpu:cpuusage:loadavg -l none";
    distro = "fastfetch -s os -l none";
  };
}
