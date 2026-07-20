return {
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nordic").setup({
        italic_comments = true,
        reduced_blue = true,
        telescope = { style = "flat" },
      })
    end,
  },
}
