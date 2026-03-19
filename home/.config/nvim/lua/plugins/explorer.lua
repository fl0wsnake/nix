return {
  'https://github.com/luukvbaal/nnn.nvim',
  init = function()
    require("nnn").setup({
      picker = {
        style = {
          width = 1,
          height = 1
        }
      }
    })
    vim.keymap.set("n", "<a-x>", function()
      vim.cmd('NnnPicker %')
    end, Silent)
  end
}
