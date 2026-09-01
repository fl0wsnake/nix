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
    "https://github.com/romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
      require("tree-sitter-manager").setup(
        { auto_install = true, }
      )
    end,
  },
  {
    'https://github.com/Bekaboo/dropbar.nvim',
    dependencies = {
      'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    },
    config = function()
      local bar = require('dropbar.bar')

      local git_relative_path_source = {
        get_symbols =
            function()
              if (vim.o.buftype ~= '') then return {} end
              local filepath = vim.fn.expand('%:p')
              if filepath == '' then return '[No Name]' end
              local git_root = vim.fn.systemlist('git -C ' ..
                vim.fn.shellescape(vim.fn.fnamemodify(filepath, ':h')) .. ' rev-parse --show-toplevel')[1]
              if vim.v.shell_error ~= 0 or not git_root then
                return {
                  bar.dropbar_symbol_t:new({
                    name = vim.fn.expand('%:p'),
                    name_hl = 'String',
                  }),
                }
              end
              local root_dirname = vim.fn.fnamemodify(git_root, ':t')
              local relative = filepath:sub(#git_root + 2) -- strip git_root + trailing slash
              if relative == '' then
                return {
                  bar.dropbar_symbol_t:new({
                    name = root_dirname,
                    name_hl = 'Title',
                  }),
                }
              end
              return {
                bar.dropbar_symbol_t:new({
                  name = root_dirname,
                  name_hl = 'Title',
                }),
                bar.dropbar_symbol_t:new({
                  name = relative,
                }) }
            end
      }

      require('dropbar').setup({
        sources = {
          treesitter = {
            max_depth = 3
          },
          lsp = {
            max_depth = 3
          }
        },
        bar = {
          sources = function(buf, _)
            local sources = require('dropbar.sources')
            local utils = require('dropbar.utils')
            if vim.bo[buf].ft == 'markdown' then
              return {
                -- sources.git_relative_path,
                git_relative_path_source,
                sources.markdown,
              }
            end
            if vim.bo[buf].buftype == 'terminal' then
              return {
                sources.terminal,
              }
            end
            return {
              git_relative_path_source,
              utils.source.fallback({
                sources.lsp,
                sources.treesitter,
              }),
            }
          end
        }
      })
      local dropbar_api = require('dropbar.api')
      -- dropbar_api.
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end
  },
  -- {
  --   'https://github.com/utilyre/barbecue.nvim',
  --   name = "barbecue",
  --   version = "*",
  --   dependencies = {
  --     "SmiteshP/nvim-navic",
  --     "nvim-tree/nvim-web-devicons", -- optional dependency
  --   },
  --   opts = {
  --     -- configurations go here
  --   },
  -- },
  {
    'https://github.com/neovim/nvim-lspconfig',
    init = function()
      vim.lsp.config["gitlab_duo"] = { filetypes = {} } -- XXX: KEEP THIS OR DIE

      vim.lsp.config["lua_ls"] = {
        settings = {
          Lua = {
            workspace = {
              library = {
                vim.env.VIMRUNTIME -- Only index runtime api
              },
            },
          },
        },
      }
      vim.diagnostic.config({
        update_in_insert = false, -- fix zls/other lsp lag
      })
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false   -- fix rust_analyzer stressing about OUT env
      capabilities.textDocument.completion.completionItem.snippetSupport = false -- disable jumps after snippet completion
      vim.lsp.config("*", {
        capabilities = capabilities
      })
      vim.lsp.config("zls", {
        on_attach = function(client, bufnr)
          client.server_capabilities.semanticTokensProvider = nil -- fix lag in 0.15.2
        end,
      })
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
      vim.lsp.config("ts_ls", {
        settings = {
          codeActionsOnSave = {
            ["source.addMissingImports"] = true
          }
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
    enabled = function()
      return vim.fn.executable("direnv") == 1
    end,
    opts = {
      -- async = true,
      on_direnv_finished = function()
        if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
          vim.cmd("lsp restart")
        end
      end,
      on_direnv_finished_opts = {
        pattern = { "DirenvReady" },
      },
    }
  },
  {
    'https://github.com/stevearc/aerial.nvim',
    init = function()
      require("aerial").setup({
        layout = {
          resize_to_content = false,
        },
        on_attach = function(bufnr)
          vim.keymap.set("n", "<s-c-a-cr>", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "<c-a-cr>", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
      vim.keymap.set("n", "<leader>o", "<cmd>AerialNavToggle<CR>")
    end
  },
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
