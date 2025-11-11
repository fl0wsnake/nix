local rb = { remap = true, buffer = 0 }
vim.keymap.set('n', '<localleader>c', 'mmysiW*`m', rb)         -- Italics
vim.keymap.set('x', '<localleader>c', 'mms*`m', rb)            -- Italics
vim.keymap.set('n', '<localleader>b', 'mmysiW*v`]o`[s*`m', rb) -- Bold
vim.keymap.set('x', '<localleader>b', 'mms*v`]o`[s*`m', rb)    -- Bold

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
          vim.keymap.set({ 'n', 'x' }, '<a-cr>', '<Plug>Markdown_MoveToNextHeader', b)
          vim.keymap.set({ 'n', 'x' }, '<s-a-cr>', '<Plug>Markdown_MoveToPreviousHeader', b)
        end
      })
    end
  },

}
