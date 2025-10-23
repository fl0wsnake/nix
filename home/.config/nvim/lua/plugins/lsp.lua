-- function K()
--   if vim.o.filetype == 'help' then -- default is `split h`
--     vim.cmd(string.format('sil! h %s', vim.fn.expand('<cword>')))
--     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>", true, false, true) .. 'T', 'x', false)
--   elseif vim.o.filetype == 'man' then -- keep default
--     vim.cmd('sil! norm! K')
--   else
--     vim.lsp.buf.hover() -- add lsp support
--   end
-- end

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
      -- local lspconfig = require('lspconfig')
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      vim.lsp.enable({
        "bashls", "jsonls", "ts_ls", "nil_ls", "lua_ls"
      })
      vim.lsp.config.bashls = {
        filetypes = { "sh", "bash", "zsh" }
      }
      vim.lsp.config("nil_ls", {
        settings = {
          ["nil"] = {
            formatting = {
              command = { "nixfmt" },
            },
          }
        }
      })
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath('config')
                and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using (most
              -- likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
              -- Tell the language server how to find Lua modules same way as Neovim
              -- (see `:h lua-module-load`)
              path = {
                'lua/?.lua',
                'lua/?/init.lua',
              },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
                -- Depending on the usage, you might want to add additional paths
                -- here.
                -- '${3rd}/luv/library'
                -- '${3rd}/busted/library'
              }
              -- Or pull in all of 'runtimepath'.
              -- NOTE: this is a lot slower and will cause issues when working on
              -- your own configuration.
              -- See https://github.com/neovim/nvim-lspconfig/issues/3189
              -- library = {
              --   vim.api.nvim_get_runtime_file('', true),
              -- }
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })
      -- vim.lsp.config("lua_ls", {
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       runtime = {
      --         version = 'LuaJIT',
      --       },
      --       diagnostics = {
      --         globals = { 'vim', 'it', 'describe', 'before_each', 'after_each' },
      --       },
      --       workspace = {
      --         library = {
      --           [vim.fn.expand("$VIMRUNTIME/lua")] = true,
      --           [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
      --           [vim.fn.stdpath("data") .. "/lazy/"] = true
      --         },
      --         checkThirdParty = false,
      --       },
      --     }
      --   }
      -- })
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
