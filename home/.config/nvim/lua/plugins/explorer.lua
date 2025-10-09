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
  end,
  dependencies = {
    'https://github.com/nvim-tree/nvim-web-devicons',
  }
}

-- return {
--   'https://github.com/luukvbaal/nnn.nvim',
--   init = function()
--     local builtin = require("nnn").builtin
--     require("nnn").setup({
--       picker = {
--         style = {
--           width = 1,
--           height = 1
--         }
--       }
--     })
--     vim.keymap.set("n", "<a-x>", function() 
--       local file = vim.fn.expand('%:p') 
--       -- vim.cmd(string.format('enew|NnnPicker %q|if expand("%%") == ""|e %q|endif', file, file)) 
--       vim.cmd('enew|NnnPicker ' .. file) 
--       -- if vim.fn.expand('%') == '' then vim.cmd('e '..file) end 
--     end, Silent)
--   end
-- }
