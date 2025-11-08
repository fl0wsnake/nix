return {
  'https://github.com/norcalli/nvim-colorizer.lua',
  init = function()
    require 'colorizer'.setup({ 'css', 'scss', 'swayconfig', 'markdown' })
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "" then
          vim.cmd('ColorizerAttachToBuffer')
        end
      end,
    })
  end
}
