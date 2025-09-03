local function root()
  return io.popen('git rev-parse --show-toplevel 2>/dev/null || pwd'):read()
end

local function lines() -- reimplementing because BLines turns search upside down
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
      "--preview", "bat --style=plain --color=always --highlight-line {1} " .. tmp_file_with_ext,
      "--preview-window", "+{1}-/2", },
    sink = function(selection)
      local line_idx = string.match(selection, '([0-9]*):')
      vim.fn.execute(line_idx)
    end,
    exit = function()
      os.execute('rm ' .. tmp_file_with_ext)
    end
  })
end

local function GFiles()
  vim.call('fzf#run', {
    dir = root(),
    source = 'rg --files --smart-case --color=never -.',
    options = {
      "--preview", "bat --style=plain --color=always {1} ",
    },
    sink = 'e',
  })
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
      vim.keymap.set('', '<leader>f', function() vim.cmd('Files') end)
      vim.keymap.set('', '<leader>r', GFiles) -- TODO change to `call fzf#run({'sink': 'tabedit'})`
      vim.keymap.set('', '<leader>h', function() vim.cmd('History') end)
      vim.keymap.set('', '<leader>m', helptags)
      vim.keymap.set('', '<leader>sf', function() vim.cmd('Rg') end)
      vim.keymap.set('', '<leader>sl', function() lines() end)
      vim.keymap.set('', '<leader>sr', function() -- Search Root
        vim.cmd(string.format('sil lcd %s', root()))
        vim.fn['fzf#vim#grep'](
          "rg --line-number --no-heading --smart-case --color=always -. -- ^",
          vim.fn['fzf#vim#with_preview']()
        )
      end)
      vim.keymap.set('', '<leader>sp', function() -- Search Plugins
        vim.cmd(string.format('sil lcd %s', vim.fn.stdpath("data")))
        vim.fn['fzf#vim#grep'](
          'rg --line-number --no-heading --smart-case --color=always -. -- ^',
          vim.fn['fzf#vim#with_preview']()
        )
      end)
      vim.keymap.set('', '<leader>a', function()
        vim.fn['fzf#run']({
          source = 'fd -LH -d8 --base-directory ~ --ignore-file=$HOME/.fuzzy-home-ignore',
          sink = 'cd ~|e'
        })
      end)
    end
  }
}
