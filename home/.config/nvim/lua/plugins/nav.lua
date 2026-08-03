---@return string
local function gitRoot()
  return io.popen('git rev-parse --show-toplevel 2>/dev/null || pwd'):read()
end

return {
  {
    "https://github.com/ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      local fzf_lua = require("fzf-lua")
      fzf_lua.setup({
        winopts = { fullscreen = true, preview = { horizontal = "right:50%" } },
        grep = {
          rg_opts = "-. --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        }
      })
      vim.keymap.set('', '<leader>sl', fzf_lua.grep_curbuf)
      vim.keymap.set('', '<leader>so', fzf_lua.lsp_document_symbols)
      vim.keymap.set('', '<leader>f', fzf_lua.files)
      vim.keymap.set('', '<leader>r', function() fzf_lua.files({ cwd = gitRoot() }) end)
      vim.keymap.set('', '<leader>sf', fzf_lua.grep_project)
      vim.keymap.set('', '<leader>sr', function()
        fzf_lua.grep_project({ fzf_opts = { ["--nth"] = "1..", }, cwd = gitRoot() })
      end)
      vim.keymap.set('', '<leader>sp', function()
        fzf_lua.grep_project({ fzf_opts = { ["--nth"] = "1..", }, cwd = vim.fn.stdpath("data"), })
      end)
      vim.keymap.set('', '<leader>m', fzf_lua.helptags)
      vim.keymap.set('', '<leader>h', fzf_lua.history)
      vim.keymap.set('', '<leader>a',
        function() fzf_lua.files({ cwd = "~", fd_opts = "-HE .git -d8 --ignore-file=$HOME/.fuzzy-home-ignore" }) end)
    end
  },
  {
    "https://github.com/ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      local Path = require("plenary.path")
      local Data = require("harpoon.data")

      local last_root
      local loaded_root

      local function root()
        local buf = vim.api.nvim_get_current_buf()

        -- When closing/saving the Harpoon menu, the current buffer is the menu
        -- buffer, not a project file. Reuse the project root that opened it.
        if vim.bo[buf].filetype == "harpoon" and last_root then
          return last_root
        end

        local dir = vim.fs.root(buf, ".git") or vim.loop.cwd()
        last_root = dir
        return dir
      end

      local function ensure_project_data()
        local dir = root()

        -- Harpoon reads its backing file during setup. If setup happened before the
        -- project buffer was current, reload the data object before decoding the list.
        if loaded_root ~= dir then
          harpoon.data = Data.Data:new(harpoon.config)
          loaded_root = dir
        end
      end

      local function list()
        ensure_project_data()
        return harpoon:list()
      end

      local function to_abs(path)
        if path:sub(1, 1) == "/" or path:match("^%a:[/\\]") then
          return path
        end

        return root() .. "/" .. path
      end

      harpoon:setup({
        settings = {
          key = root,
          save_on_toggle = true,
        },
        default = {
          get_root_dir = root,
          create_list_item = function(config, name)
            name = name or Path:new(vim.api.nvim_buf_get_name(0)):make_relative(config.get_root_dir())
            return {
              value = name,
              context = {},
            }
          end,
          select = function(list_item, _, options)
            if not list_item then
              return
            end
            options = options or {}
            local path = vim.fn.fnameescape(to_abs(list_item.value))
            if options.vsplit then
              vim.cmd("vsplit " .. path)
            elseif options.split then
              vim.cmd("split " .. path)
            elseif options.tabedit then
              vim.cmd("tabedit " .. path)
            else
              vim.cmd("edit " .. path)
            end
          end,
        },
      })

      vim.keymap.set("n", "<a-`>", function() list():add() end)
      vim.keymap.set("n", "<a-space>", function() harpoon.ui:toggle_quick_menu(list()) end)
      vim.keymap.set("n", "<a-1>", function() list():select(1) end)
      vim.keymap.set("n", "<a-2>", function() list():select(2) end)
      vim.keymap.set("n", "<a-3>", function() list():select(3) end)
      vim.keymap.set("n", "<a-4>", function() list():select(4) end)
      vim.keymap.set("n", "<a-5>", function() list():select(5) end)
      vim.keymap.set("n", "<a-6>", function() list():select(6) end)
      vim.keymap.set("n", "<a-7>", function() list():select(7) end)
      vim.keymap.set("n", "<a-8>", function() list():select(8) end)
      vim.keymap.set("n", "<a-9>", function() list():select(9) end)
    end
  },
}
