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
  local col = vim.fn.match(vim.fn.getline('.'), [[\S]]) + 1
  local line = vim.fn.line('.')
  while line < vim.api.nvim_buf_line_count(0) do
    line = line + 1
    vim.fn.cursor(line, col)
    if (vim.fn.getline(line)):sub(col, col):match('^%S$') then
      break
    end
  end
end

function Up_v()
  local col = vim.fn.match(vim.fn.getline('.'), [[\S]]) + 1
  local line = vim.fn.line('.')
  while line > 0 do
    line = line - 1
    vim.fn.cursor(line, col)
    if (vim.fn.getline(line)):sub(col, col):match('^%S$') then
      break
    end
  end
end

function Sort_paragraph(reverse)
  return function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] -- 1-indexed

    local start = row
    while start > 1 and vim.fn.getline(start - 1) ~= "" do
      start = start - 1
    end

    local last = vim.fn.line("$")
    local finish = row
    while finish < last and vim.fn.getline(finish + 1) ~= "" do
      finish = finish + 1
    end

    local lines = vim.api.nvim_buf_get_lines(0, start - 1, finish, false)
    table.sort(lines, function(a, b)
      return reverse and a > b or a < b
    end)
    vim.api.nvim_buf_set_lines(0, start - 1, finish, false, lines)

    local target = math.max(start, math.min(row, finish))
    vim.api.nvim_win_set_cursor(0, { target, cursor[2] })
  end
end
