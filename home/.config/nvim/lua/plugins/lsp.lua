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
vim.keymap.set({ 'i', '' }, '<c-s-k>', vim.lsp.buf.signature_help)
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

local function scroll_hover(delta)
  local cmd
  if (delta < 0) then
    cmd = "norm! " .. math.abs(delta) .. "k"
  else
    cmd = "norm! " .. delta .. "j"
  end
  return function()
    local winid = vim.b.lsp_floating_preview
    if winid and vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_call(winid, function()
        vim.cmd(cmd)
      end)
    end
  end
end
vim.keymap.set("n", "<C-n>", scroll_hover(4))
vim.keymap.set("n", "<C-p>", scroll_hover(-4))


return {
  {
    'https://github.com/neovim/nvim-lspconfig',
    init = function()
      vim.lsp.inlay_hint.enable(false)
      vim.diagnostic.config({
        update_in_insert = false, -- fix zls/other lsp lag
      })
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false   -- fix rust_analyzer stressing about OUT env
      capabilities.textDocument.completion.completionItem.snippetSupport = false -- disable jumps after snippet completion
      vim.lsp.config("*", {
        capabilities = capabilities
      })
      -- vim.lsp.config("zls", {
      --   autostart = false,
      --   on_attach = function(client, bufnr)
      --     client.server_capabilities.semanticTokensProvider = nil -- fix lag
      --   end,
      -- })
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })
      vim.lsp.config("clangd", {
        cmd = { 'clangd', '--query-driver=/run/current-system/sw/bin/gcc,/run/current-system/sw/bin/clang' }
      })
      vim.lsp.config("ts_ls", {
        settings = {
          codeActionsOnSave = {
            ["source.addMissingImports"] = true
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
      vim.lsp.enable({
        "gopls",
        "golangci_lint_ls",
        "zls",    -- run by direnv
        "html",   -- for formatting
        "bashls", -- on zsh files it just eats a cpu
        "jsonls",
        "ts_ls",
        "cssls",
        "rust_analyzer",
        "nixd",
        "lua_ls",
        "basedpyright",
        "ruff",
        "clangd", -- ccls is worse & creates huge .ccls-cache dirs
        "just",
      })
    end
  },
  {
    "https://github.com/actionshrimp/direnv.nvim",
    opts = {
      async = true,
      on_direnv_finished = function()
        -- vim.cmd("LspStart zls")
      end
    }
  },
  -- { deprecated?
  --   'https://github.com/stevearc/aerial.nvim',
  --   init = function()
  --     require("aerial").setup({
  --       on_attach = function(bufnr)
  --         vim.keymap.set("n", "<s-c-a-cr>", "<cmd>AerialPrev<CR>", { buffer = bufnr })
  --         vim.keymap.set("n", "<c-a-cr>", "<cmd>AerialNext<CR>", { buffer = bufnr })
  --       end,
  --     })
  --     vim.keymap.set("n", "<leader>o", "<cmd>AerialNavToggle<CR>")
  --   end
  -- },
  -- {
  --   'https://github.com/nvimtools/none-ls.nvim',
  --   dependencies = { 'https://github.com/nvim-lua/plenary.nvim' },
  --   init = function()
  --     local null_ls = require("null-ls")
  --     null_ls.setup {
  --       sources = {
  --         -- null_ls.builtins.formatting.prettier, -- works for markdown, but do I want it there?
  --         null_ls.builtins.formatting.black,
  --       }
  --     }
  --   end
  -- },

  -- {
  --   'https://github.com/lukas-reineke/lsp-format.nvim', -- writes buffers async after formatting
  --   init = function()
  --     require("lsp-format").setup {}
  --     vim.api.nvim_create_autocmd('LspAttach', {
  --       callback = function(args)
  --         local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
  --         require("lsp-format").on_attach(client, args.buf)
  --       end,
  --     })
  --   end
  -- }
}
