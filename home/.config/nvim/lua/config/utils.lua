function ansi_colorize() -- for browsing kitty scrollback
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  while #lines > 0 and vim.trim(lines[#lines]) == "" do
    lines[#lines] = nil
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, "\r\n"))
  vim.cmd("normal! G0")
  vim.keymap.set("", "i", "<Nop>", {})
  vim.keymap.set("", "I", "<Nop>", {})
  vim.keymap.set("", "a", "<Nop>", {})
  vim.keymap.set("", "A", "<Nop>", {})
  vim.keymap.set("", "o", "<Nop>", {})
  vim.keymap.set("", "O", "<Nop>", {})
end

vim.cmd('command! AnsiColorize lua ansi_colorize()')

function Down_v()
  local col = vim.fn.col('.')
  local line = vim.fn.line('.')
  while true do
    line = line + 1
    vim.fn.cursor(line, col)
    if (vim.fn.getline(line)):sub(col, col):match('^%S$') then
      break
    end
  end
end

function Up_v()
  local col = vim.fn.col('.')
  local line = vim.fn.line('.')
  while true do
    line = line - 1
    vim.fn.cursor(line, col)
    if (vim.fn.getline(line)):sub(col, col):match('^%S$') then
      break
    end
  end
end
