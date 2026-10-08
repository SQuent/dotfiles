{ ... }:
{
  programs.lazyvim.enable = true;

  # Colours come from Stylix's own neovim target (enabled in
  # home/theme/stylix.nix): it puts mini.nvim on programs.neovim.plugins —
  # so the plugin is managed by Nix rather than fetched from GitHub by
  # lazy.nvim — and calls mini.base16's setup at the top of init.lua.
  programs.lazyvim.plugins.stylix-colorscheme = ''
    return {
      {
        "LazyVim/LazyVim",
        opts = {
          colorscheme = function()
            local base16 = require("mini.base16")
            base16.setup(base16.config)
          end,
        },
      },
    }
  '';

  home.sessionVariables.EDITOR = "nvim";

  programs.zsh.shellAliases = {
    vi = "vim";
    vim = "nvim";
    vdiff = "nvim -d";
  };
}
