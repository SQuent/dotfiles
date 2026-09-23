{ ... }:
{
  programs.lazyvim.enable = true;

  # Colours come from Stylix's own neovim target (enabled in
  # home/theme/stylix.nix): it puts mini.nvim on programs.neovim.plugins —
  # so the plugin is managed by Nix rather than fetched from GitHub by
  # lazy.nvim — and calls mini.base16's setup at the top of init.lua.
  #
  # That alone isn't enough under LazyVim, which applies its own colorscheme
  # afterwards (vim.cmd.colorscheme in lazyvim/config/init.lua) and would
  # replace it with tokyonight. LazyVim accepts a *function* for `colorscheme`
  # and calls it at exactly the right moment, so just re-apply what Stylix
  # already configured.
  #
  # Deliberately no palette in here: this file has to stay byte-identical from
  # one generation to the next. Everything under lua/ is bytecode-cached by
  # vim.loader in ~/.cache/nvim/luac, keyed by path and validated on
  # mtime+size — and every file in the Nix store carries mtime 1970-01-01
  # while the path never changes, so that cache never invalidates. Holding the
  # palette here is what made theme switches silently stop applying.
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
