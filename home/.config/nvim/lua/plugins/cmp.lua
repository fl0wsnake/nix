return {
  'https://github.com/hrsh7th/nvim-cmp',
  dependencies = {
    'https://github.com/hrsh7th/cmp-nvim-lsp',
    'https://github.com/hrsh7th/cmp-buffer',
    'https://github.com/hrsh7th/cmp-path',
    {
      'https://github.com/saadparwaiz1/cmp_luasnip',
      dependencies = {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        init = function()
          local luasnip = require 'luasnip'
          vim.keymap.set({ 'i', 's' }, '<c-j>', function() if luasnip.locally_jumpable(1) then luasnip.jump(1) end end)
          vim.keymap.set({ 'i', 's' }, '<c-k>', function() if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end end)
        end
      },
    }
  },
  init = function()
    local cmp = require 'cmp'
    require("luasnip.loaders.from_vscode").lazy_load()
    cmp.setup {
      completion = {
        autocomplete = { "InsertEnter", "TextChanged" },
      },
      sources = {
        { name = 'nvim_lsp', },
        { name = 'luasnip', },
        { name = 'path', },
        { name = 'buffer', },
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-space>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
    }
  end
}
