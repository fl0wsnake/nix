return {
  {
    -- fork with lsp restart fix of https://github.com/actionshrimp/direnv.nvim
    "https://github.com/fl0wsnake/direnv.nvim",
    lazy = false,
    config = function()
      require("direnv-nvim").setup {}
    end,
  },
}
