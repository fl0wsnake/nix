return {
  'https://github.com/nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  init = function()
    require 'nvim-treesitter'.setup {}

    -- vim.api.nvim_create_autocmd('FileType', {
    --   callback = function(args)
    --     if vim.bo[args.buf].filetype == 'ipkg' then
    --       return
    --     end
    --     pcall(vim.treesitter.start, args.buf)
    --   end,
    -- })

  end
}
