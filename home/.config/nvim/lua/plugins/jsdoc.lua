return {
  'https://github.com/heavenshell/vim-jsdoc',
  build = "make install",
  init = function()
    vim.keymap.set("n", "<localleader>j", '<Plug>(jsdoc)')
  end
}
