return {
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
}
