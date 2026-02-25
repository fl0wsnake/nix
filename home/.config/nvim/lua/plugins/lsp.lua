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

vim.keymap.set('n', '<c-cr>', function() vim.diagnostic.jump { count = 1, float = true } end)
vim.keymap.set('n', '<s-c-cr>', function() vim.diagnostic.jump { count = -1, float = true } end)
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

return {
  {
    'https://github.com/direnv/direnv.vim',
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvLoaded",
        callback = function()
          vim.cmd("LspRestart")
        end,
      })
    end
  },
  {
    'https://github.com/stevearc/aerial.nvim',
    init = function()
      require("aerial").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "<s-c-a-cr>", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "<c-a-cr>", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
      vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle left<CR>")
    end
  },
  {
    'https://github.com/neovim/nvim-lspconfig',
    init = function()
      vim.lsp.enable({
        "gopls",
        "golangci-lint-langserver",
        "zls",
        "html", -- for formatting
        "bashls",
        "jsonls",
        "ts_ls",
        "nixd",
        "lua_ls",
        "basedpyright",
        "ruff",
        "clangd", -- ccls is worse & creates huge .ccls-cache dirs
      })
      vim.lsp.config.gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true, -- Set to true if you use gofumpt
          },
        },
      }
      vim.lsp.config.clangd = {
        cmd = { 'clangd', '--query-driver=/run/current-system/sw/bin/gcc,/run/current-system/sw/bin/clang' }
      }
      vim.lsp.config.ts_ls = {
        settings = {
          codeActionsOnSave = {
            ["source.addMissingImports"] = true
          }
        }
      }
      vim.lsp.config.bashls = {
        filetypes = { "sh", "bash" }
      }
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
              version = 'LuaJIT',
              path = {
                'lua/?.lua',
                'lua/?/init.lua',
              },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              }
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })
    end
  },
  {
    'https://github.com/nvimtools/none-ls.nvim',
    dependencies = { 'https://github.com/nvim-lua/plenary.nvim' },
    init = function()
      local null_ls = require("null-ls")
      null_ls.setup {
        sources = {
          -- null_ls.builtins.formatting.prettier, -- works for markdown, but do I want it there?
          null_ls.builtins.formatting.black,
        }
      }
    end
  },
  {
    'https://github.com/lukas-reineke/lsp-format.nvim', -- writes buffers async after formatting
    init = function()
      require("lsp-format").setup {}
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          require("lsp-format").on_attach(client, args.buf)
        end,
      })
    end
  }
}
