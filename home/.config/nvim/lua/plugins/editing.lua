--- Yank buffer
vim.keymap.set("n", "<leader>D", "D", Silent)
vim.keymap.set("n", "<leader>C", "C", Silent)
vim.keymap.set("", "<leader>d", "d", Silent)
vim.keymap.set("n", "<leader>dd", "dd", Silent)
vim.keymap.set("n", "<leader>dD", "_d$", Silent)
vim.keymap.set("n", "yY", "_y$$", Silent)

return {
  {
    'https://github.com/jiangmiao/auto-pairs',
    'https://github.com/windwp/nvim-ts-autotag', -- autoclose and autorename html tag
    init = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_rename = true,
          enable_close = true,
          enable_close_on_slash = true,
        }
      })
    end
  },
  'https://github.com/tpope/vim-repeat', -- surround.vim speeddating.vim unimpaired.vim vim-easyclip vim-radical
  {
    'https://github.com/tpope/vim-surround',
    init = function()
      vim.keymap.set("v", "s", "S", { remap = true }) -- for it keeps old `s` 'Delete n characters and start insert' behavior
    end
  },
  {
    'https://github.com/svermeulen/vim-easyclip', -- For `s`ubstitute bindings
    init = function()
      vim.g.EasyClipUseCutDefaults = false        -- For `M`oveMotionPlug, `M`oveMotionXPlug, `M`oveMotionLinePlug overriding `m`
      vim.g.EasyClipUseSubstituteDefaults = true  -- Override default `s` 'Delete n characters and start insert' behavior
      -- vim.g.EasyClipAutoFormat = true -- `=` pasted lines <- often butchers text TODO remove
    end
  },
  'https://github.com/glts/vim-radical', -- `gA` to convert decimal, hex, octal, binary numbers
  'https://github.com/michaeljsmith/vim-indent-object'
}
