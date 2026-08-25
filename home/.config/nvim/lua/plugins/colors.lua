return {
  -- {
  --   "https://github.com/folke/todo-comments.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {}
  -- },
  {
    'https://github.com/catgoose/nvim-colorizer.lua',
    init = function()
      vim.keymap.set("", "<a-c>", function()
        vim.cmd('ColorizerToggle')
      end, Silent)
      require 'colorizer'.setup({
        options = { parsers = { names = { enable = false } } },
        'css',
        'scss',
        'swayconfig',
        'markdown',
        'toml',
      })
    end
  },
  {
    'https://github.com/ellisonleao/gruvbox.nvim',
    init = function()
      require "gruvbox".setup({
        overrides = {
          mkdLink = { fg = '#FF4499' },    -- Pink
          ['mkdCode'] = { fg = '#79C0FF' } -- LightBlue
        },
        italic = {
          strings = false,
          emphasis = true,
          comments = false,
          operators = false,
          folds = true,
        },
      })
      vim.cmd('colorscheme gruvbox')
      vim.cmd('highlight Normal guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE')
    end
  },
}
