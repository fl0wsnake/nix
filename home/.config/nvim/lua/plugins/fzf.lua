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
    -- string.format("grep -Eho '^\\S*' %s",
        string.format(
          "cat %s | cut -d'\t' -f1,2 | column -t -s'\t' -C strictwidth=20",
          table.concat(vim.fn.globpath(vim.o.runtimepath, 'doc/tags', true, true), ' ')
        ),
    -- options = {
    --   "--preview", "bat --style=plain --color=always {2} ",
    -- },
    sink = function(selection)
      vim.cmd('tab h ' .. string.match(selection, '^[^ ]*'))
    end,
  })
end

return {
  {
    'https://github.com/junegunn/fzf.vim',
    dependencies = {
      {
        'https://github.com/junegunn/fzf',
        -- build = function() vim.fn['fzf#install']() end,
      }
    },
    init = function()
      vim.g.fzf_layout = { window = 'enew' }
      vim.keymap.set('', '<leader>sl', blines)
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
