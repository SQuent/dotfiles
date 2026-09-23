{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.enable = true;

  home.sessionVariables = {
    XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
    XDG_LIB_HOME = "${config.home.homeDirectory}/.local/lib";

    PIP_CONFIG_FILE = "${config.xdg.configHome}/pip/pip.conf";
    PIP_LOG_FILE = "${config.xdg.dataHome}/pip/log";
    CURL_HOME = "${config.xdg.configHome}/curl";
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    # X11 display — Linux only (matches previous `[[ "$OS" == "linux" ]] && export DISPLAY=:0`)
    DISPLAY = ":0";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
}
