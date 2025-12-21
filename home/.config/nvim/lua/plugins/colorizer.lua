return {
  'https://github.com/norcalli/nvim-colorizer.lua',
  init = function()
    vim.keymap.set("", "<a-c>", function()
      vim.cmd('ColorizerToggle')
    end, Silent)
    require 'colorizer'.setup({ 'css', 'scss', 'swayconfig', 'markdown', 'toml', })
  end
}
