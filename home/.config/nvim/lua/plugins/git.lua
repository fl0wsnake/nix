return {
  -- {
  --   'https://github.com/tpope/vim-fugitive',
  --   init = function()
  --     vim.keymap.set("", "<leader>gd", function() vim.cmd('Gvdiffsplit') end)
  --   end
  -- },
  {
    'https://github.com/airblade/vim-gitgutter',
    init = function()
      vim.o.updatetime = 100
      vim.keymap.set('', '<s-c-cr>', '[c', { remap = true })
      vim.keymap.set('', '<c-cr>', ']c', { remap = true })
    end
  },
  {},
  {
    "https://github.com/sindrets/diffview.nvim",
    init = function()
      vim.keymap.set('', '<leader>gD', function() return vim.cmd('DiffviewOpen') end)
      vim.keymap.set('', '<leader>gh', function() return vim.cmd('DiffviewFileHistory') end)
      vim.keymap.set('', '<leader>gc', function() return vim.cmd('DiffviewClose') end)
    end
  }
}
