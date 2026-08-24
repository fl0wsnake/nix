return {
  -- {
  --   "https://github.com/folke/todo-comments.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {}
  -- },

  'https://github.com/catgoose/nvim-colorizer.lua',
  init = function()
    vim.keymap.set("", "<a-c>", function()
      vim.cmd('ColorizerToggle')
    end, Silent)
    require 'colorizer'.setup({ 'css', 'scss', 'swayconfig', 'markdown', 'toml', })
  end

}
