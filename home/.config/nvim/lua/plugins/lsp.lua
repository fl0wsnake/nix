vim.keymap.set('n', '<a-cr>', function() vim.diagnostic.jump { count = 1, float = true } end)
vim.keymap.set('n', '<s-a-cr>', function() vim.diagnostic.jump { count = -1, float = true } end)
vim.keymap.set('n', '<localleader>D', vim.lsp.buf.declaration)
vim.keymap.set('n', '<localleader>d', vim.lsp.buf.definition)
vim.keymap.set('n', '<localleader>i', vim.lsp.buf.implementation)
vim.keymap.set('n', '<localleader>t', vim.lsp.buf.type_definition)
vim.keymap.set({ 'i', '' }, '<s-c-k>', vim.lsp.buf.signature_help)
vim.keymap.set('n', '<localleader>wa', vim.lsp.buf.add_workspace_folder)
vim.keymap.set('n', '<localleader>wr', vim.lsp.buf.remove_workspace_folder)
vim.keymap.set('n', '<localleader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
vim.keymap.set('n', '<localleader>r', vim.lsp.buf.rename)
vim.keymap.set({ 'n', 'v' }, '<localleader>a', vim.lsp.buf.code_action)
vim.keymap.set('n', '<localleader>R', vim.lsp.buf.references)
vim.keymap.set('', '<localleader>f', function() vim.lsp.buf.format { async = true } end)
vim.g.fmt_on_save = true
vim.keymap.set('', '<a-f>', function()
  vim.g.fmt_on_save = not vim.g.fmt_on_save
  print("fmt_on_save == " .. tostring(vim.g.fmt_on_save))
end)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = '*', callback = function() if vim.g.fmt_on_save then vim.lsp.buf.format() end end
})


return {
  {
    'https://github.com/neovim/nvim-lspconfig',
    init = function()
      local lspconfig = require('lspconfig')
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      vim.lsp.enable('bashls')
      lspconfig.jsonls.setup { capabilities = capabilities, }
      lspconfig.ts_ls.setup {}
      lspconfig.nil_ls.setup {
        settings = {
          ["nil"] = {
            formatting = {
              command = { "nixfmt" },
            },
          }
        }
      }
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim', 'it', 'describe', 'before_each', 'after_each' },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                [vim.fn.stdpath("data") .. "/lazy/"] = true
              },
              checkThirdParty = false,
            },
          } }
      }
    end
  },
  {
    'https://github.com/nvimtools/none-ls.nvim',
    dependencies = { 'https://github.com/nvim-lua/plenary.nvim' },
    init = function()
      local null_ls = require("null-ls")
      null_ls.setup {
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.black,
        }
      }
    end
  },
}
