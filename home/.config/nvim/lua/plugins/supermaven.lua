return {
  "https://github.com/supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<c-f>",
        accept_word = "<c-s-f>",
      },
    })
    -- vim.cmd('SupermavenUseFree')
  end,
}
