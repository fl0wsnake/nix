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
      vim.o.updatetime = 100 -- fix unreasonably big delay
      vim.keymap.set('', '<a-g>', '<Plug>(GitGutterPreviewHunk)')
      vim.keymap.set('', '<leader>gd', function() vim.cmd('GitGutterDiffOrig') end)
      vim.keymap.set('', '<s-c-cr>', '<Plug>(GitGutterPrevHunk)')
      vim.keymap.set('', '<c-cr>', '<Plug>(GitGutterNextHunk)')
    end
  },
  {},
  {
    "https://github.com/sindrets/diffview.nvim",
    init = function()
      vim.keymap.set('', '<leader>gr', function() return vim.cmd('DiffviewOpen') end)
      vim.keymap.set('', '<leader>gh', function() return vim.cmd('DiffviewFileHistory') end)
      vim.keymap.set('', '<leader>gc', function() return vim.cmd('DiffviewClose') end)
    end
  }
}
