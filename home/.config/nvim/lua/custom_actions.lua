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

vim.cmd('command! AnsiColorize lua ansi_colorize()') -- for kitty

local function indent_level(line, tabstop)
  if line:match('^%s*$') then
    return -1 -- Empty lines have their own indent level.
  end

  local leading_whitespace = line:match('^[ \t]*')
  local columns = 0
  for whitespace in leading_whitespace:gmatch('[ \t]') do
    if whitespace == '\t' then
      columns = columns + tabstop - columns % tabstop
    else
      columns = columns + 1
    end
  end
  return columns
end

local function move_indent_island(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local slice_start_row, lines, cursor_slice_index
  if direction > 0 then
    slice_start_row = cursor[1] - 1
    lines = vim.api.nvim_buf_get_lines(buf, slice_start_row, -1, false)
    cursor_slice_index = 1
  else
    slice_start_row = 0
    lines = vim.api.nvim_buf_get_lines(buf, 0, cursor[1], false)
    cursor_slice_index = #lines
  end
  local tabstop = vim.bo[buf].tabstop
  local target_indent = indent_level(lines[cursor_slice_index], tabstop)
  local candidate_slice_index = cursor_slice_index + direction

  while candidate_slice_index >= 1 and candidate_slice_index <= #lines and indent_level(lines[candidate_slice_index], tabstop) == target_indent do
    candidate_slice_index = candidate_slice_index + direction
  end
  while candidate_slice_index >= 1 and candidate_slice_index <= #lines and indent_level(lines[candidate_slice_index], tabstop) ~= target_indent do
    candidate_slice_index = candidate_slice_index + direction
  end

  if candidate_slice_index >= 1 and candidate_slice_index <= #lines then
    vim.api.nvim_win_set_cursor(0, { slice_start_row + candidate_slice_index, cursor[2] })
  end
end

function indent_island_prev()
  move_indent_island(-1)
end

function indent_island_next()
  move_indent_island(1)
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
