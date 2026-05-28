---@return string
local function gitRoot()
  return io.popen('git rev-parse --show-toplevel 2>/dev/null || pwd'):read()
end

---@return string
local function pwd()
  return vim.fn.getcwd()
end

local function blines() -- reimplementing because BLines turns search upside down
  local source = vim.fn.map(vim.fn.getline(1, '$'), function(i, e)
    return string.format('%s:%s', i + 1, e)
  end)
  local text = table.concat(source, "\n")
  local mktemp = io.popen('mktemp /tmp/fzf-XXX')
  local tmp_file = mktemp:read("l")
  mktemp:close()
  local tmp_file_with_ext = tmp_file .. '.' .. vim.fn.expand('%:e')
  os.execute(string.format('mv %s %s', tmp_file, tmp_file_with_ext))
  local file = io.open(tmp_file_with_ext, 'w')
  file:write(text)
  file:close()
  vim.call('fzf#run', {
    source = source,
    options = {
      "-d", ":",
      "--nth", "2..",
      "--preview", "bat --style=plain --color=always -H {1} " .. tmp_file_with_ext,
      "--preview-window", "+{1}-/2", },
    sink = function(selection)
      local line_idx = string.match(selection, '^([0-9]*):')
      vim.cmd(line_idx)
    end,
    exit = function()
      os.execute('rm ' .. tmp_file_with_ext)
    end
  })
end

--- @param basedir function
--- @return function
local function Files(basedir)
  return function()
    local basedir = basedir()
    local is_multi = false
    vim.call('fzf#run', {
      dir = basedir,
      source = 'rg --files --smart-case --color=never -.',
      options = {
        "--bind", "tab:toggle", "-m", "--preview", "bat --style=plain --color=always {1} ",
      },
      sink = function(sel)
        local sel = basedir .. '/' .. sel
        if is_multi then
          vim.cmd('tabe ' .. sel)
        else
          vim.cmd('e ' .. sel)
        end
        is_multi = true
      end
    })
  end
end

--- @param basedir function
--- @return function
local function FileLines(basedir)
  return function()
    local basedir = basedir()
    local is_multi = false
    vim.call('fzf#run', {
      dir = basedir,
      source = 'rg --line-number --no-heading --smart-case --color=always -. -- ^',
      options = {
        "-m",
        "--bind", "tab:toggle",
        "-d", ":",
        "--preview-window", "+{2}-/2,~1",
        "--preview", "bat --style=header-filename --color=always -H {2} {1}",
      },
      sink = function(sel)
        local sel = sel:gmatch('[^:]+')
        local file = basedir .. '/' .. sel()
        if is_multi then
          vim.cmd('tabe ' .. file)
        else
          vim.cmd('e ' .. file)
        end
        vim.cmd(sel())
        is_multi = true
      end
    })
  end
end

local function helptags()
  vim.call('fzf#run', {
    source =
        string.format(
          "cat %s | cut -d'\t' -f1,2 | column -t -s'\t' -C strictwidth=20",
          table.concat(vim.fn.globpath(vim.o.runtimepath, 'doc/tags', true, true), ' ')
        ),
    sink = function(selection)
      vim.cmd('tab h ' .. string.match(selection, '^[^ ]*'))
    end,
  })
end

local function fzf_lsp_symbols()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, function(err, result, _, _)
    if err or not result then return end

    local items = {}
    local function flatten(res)
      for _, symbol in ipairs(res) do
        table.insert(items, string.format("%d: %s", symbol.range.start.line + 1, symbol.name))
        if symbol.children then flatten(symbol.children) end
      end
    end
    flatten(result)
    table.sort(items, function(a, b)
      return tonumber(a:match("([^:]+)")) > tonumber(b:match("([^:]+)"))
    end)

    vim.fn['fzf#run'](vim.fn['fzf#wrap']({
      source = items,
      sink = function(selected)
        local line = selected:match("(%d+):")
        vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
      end
    }))
  end)
end

return {
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
  {
    'https://github.com/junegunn/fzf.vim',
    dependencies = {
      {
        'https://github.com/junegunn/fzf',
      }
    },
    init = function()
      vim.g.fzf_layout = { window = 'enew' }
      vim.keymap.set('', '<leader>sl', blines)
      vim.keymap.set('', '<leader>so', fzf_lsp_symbols)
      vim.keymap.set('', '<leader>f', Files(pwd))
      vim.keymap.set('', '<leader>r', Files(gitRoot))
      vim.keymap.set('', '<leader>sf', FileLines(pwd))
      vim.keymap.set('', '<leader>sr', FileLines(gitRoot))
      vim.keymap.set('', '<leader>sp', FileLines(function() return vim.fn.stdpath("data") end))
      vim.keymap.set('', '<leader>m', helptags)
      vim.keymap.set('', '<leader>h', function() vim.cmd('History') end)
      vim.keymap.set('', '<leader>a', function()
        vim.fn['fzf#run']({
          source = 'fd -HE .git -d8 --base-directory ~ --ignore-file=$HOME/.fuzzy-home-ignore',
          sink = 'cd ~|e'
        })
      end)
    end
  }
}
