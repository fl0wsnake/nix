vim.keymap.set('n', '<localleader>z', function() -- to read code docs
  local word = vim.fn.expand('<cword>')
  local cache_dir = vim.fn.expand('~/.cache/zig')

  -- Run ripgrep
  local result = vim.fn.systemlist('rg --vimgrep -m 1 ' ..
    vim.fn.shellescape(word) .. ' ' .. vim.fn.shellescape(cache_dir))

  if vim.v.shell_error ~= 0 or #result == 0 then
    vim.notify('No match found for: ' .. word, vim.log.levels.WARN)
    return
  end

  -- Parse first result: file:line:col:match
  local first = result[1]
  local file, line, col = first:match('^(.-):(%d+):(%d+):')

  if not file then
    vim.notify('Failed to parse rg output', vim.log.levels.ERROR)
    return
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(file))
  vim.api.nvim_win_set_cursor(0, { tonumber(line), tonumber(col) - 1 })
end, { desc = 'Jump to first rg match in ~/.cache/zig' })
