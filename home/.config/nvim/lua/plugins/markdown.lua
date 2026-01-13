return {
  -- {
  --   'https://github.com/Nedra1998/nvim-mdlink',
  --   init = function()
  --     require('nvim-mdlink').setup({
  --       keymap = true,
  --       cmp = true
  --     })
  --   end
  -- },

  {
    'https://github.com/preservim/vim-markdown',
    init = function()
      vim.o.conceallevel = 2
      vim.g.vim_markdown_folding_disabled = 1
      vim.api.nvim_create_autocmd("FileType", {
        pattern = 'markdown',
        callback = function()
          local b = { buffer = 0 }
          vim.keymap.set({ 'n', 'x' }, '<c-cr>', '<Plug>Markdown_MoveToNextHeader', b)
          vim.keymap.set({ 'n', 'x' }, '<c-s-cr>', '<Plug>Markdown_MoveToPreviousHeader', b)
        end
      })
    end
  },

}
