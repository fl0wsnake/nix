return {
  { -- for blame
    'https://github.com/tpope/vim-fugitive',
    init = function()
      vim.keymap.set("", "<leader>gb", function() vim.cmd('Git blame') end)
    end
  },
  {
    'https://github.com/airblade/vim-gitgutter',
    init = function()
      vim.o.updatetime = 100 -- fix unreasonably big delay
      vim.keymap.set('', '<a-z>', '<Plug>(GitGutterPreviewHunk)')
      vim.keymap.set('', '<a-s>', '<Plug>(GitGutterStageHunk)')
      vim.keymap.set('', '<a-u>', '<Plug>(GitGutterUndoHunk)')
      vim.keymap.set('', '<leader>gd', function() vim.cmd('GitGutterDiffOrig') end)
      vim.keymap.set('', '<s-a-cr>', '<Plug>(GitGutterPrevHunk)')
      vim.keymap.set('', '<a-cr>', '<Plug>(GitGutterNextHunk)')
    end
  },
  {
    "https://github.com/sindrets/diffview.nvim",
    init = function()
      require('diffview').setup {}
      vim.keymap.set('', '<leader>gr', function()
        vim.cmd('DiffviewOpen')
        vim.fn.setreg("/", "")
      end)
      vim.keymap.set('', '<leader>gh', function() vim.cmd('DiffviewFileHistory') end)
      vim.keymap.set('', '<leader>gc', function() vim.cmd('DiffviewClose') end)
    end
  }
}
