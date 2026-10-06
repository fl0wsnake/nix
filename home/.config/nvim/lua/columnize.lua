local function split_on_separator(line, sep)
  local fields = {}
  local start = 1

  while true do
    local sep_start, sep_end = line:find(sep, start, true)
    if not sep_start then
      fields[#fields + 1] = line:sub(start)
      return fields
    end

    fields[#fields + 1] = line:sub(start, sep_start - 1)
    start = sep_end + 1
  end
end

local function read_separator()
  vim.api.nvim_echo({ { 'Separator (Esc cancels): ', 'Question' } }, false, {})
  local sep = vim.fn.getcharstr()
  vim.api.nvim_echo({}, false, {})

  if sep == '\27' then return nil end
  if sep == '<Tab>' then return '\t' end
  return sep
end

local function columnize_range(start_line, end_line, sep)
  if not sep or sep == '' then return end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then return end

  local rows = {}
  local widths = {}
  local max_fields = 0

  for i, line in ipairs(lines) do
    local fields = split_on_separator(line, sep)
    rows[i] = fields
    max_fields = math.max(max_fields, #fields)
  end

  local column_start = 0
  for column = 1, max_fields - 1 do
    local width = 0
    for _, fields in ipairs(rows) do
      if fields[column] then
        width = math.max(width, vim.fn.strdisplaywidth(fields[column], column_start))
      end
    end
    widths[column] = width
    local sep_start = column_start + width
    column_start = sep_start + vim.fn.strdisplaywidth(sep, sep_start)
  end

  local output = {}
  for row_index, fields in ipairs(rows) do
    local parts = {}
    local field_start = 0
    for column = 1, #fields - 1 do
      local field = fields[column]
      local field_width = vim.fn.strdisplaywidth(field, field_start)
      local padding = math.max(0, widths[column] - field_width)
      parts[#parts + 1] = field .. string.rep(' ', padding) .. sep

      local sep_start = field_start + widths[column]
      field_start = sep_start + vim.fn.strdisplaywidth(sep, sep_start)
    end
    parts[#parts + 1] = fields[#fields]
    output[row_index] = table.concat(parts)
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, output)
end

vim.api.nvim_create_user_command('Columnize', function(opts)
  columnize_range(opts.line1, opts.line2, read_separator())
end, { range = true, desc = 'Align columns before a separator' })

function _G.columnize_operator()
  local start_line = vim.fn.line("'[")
  local end_line = vim.fn.line("']")
  columnize_range(start_line, end_line, read_separator())
end
