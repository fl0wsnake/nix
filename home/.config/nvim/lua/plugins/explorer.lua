return {
  'https://github.com/stevearc/oil.nvim',
  init = function()
    require('oil').setup({ -- https://github.com/stevearc/oil.nvim?tab=readme-ov-file#options
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, bufnr)
          return name:match("^%.%.")
        end,
      },
      keymaps = {
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = false,
      }
    })
    vim.keymap.set('', '<A-x>', function() vim.cmd('Oil') end, Silent)
    vim.api.nvim_create_autocmd("BufEnter", -- autochdir
      {
        pattern = "oil://*",
        callback = function()
          local dir = require("oil").get_current_dir()
          if dir then vim.cmd.cd(dir) end
        end,
      })
  end,
  dependencies = {
    'https://github.com/nvim-tree/nvim-web-devicons',
  }
}
