vim.cmd('setl sw=2 sts=0 lbr noexpandtab')
vim.o.conceallevel = 2

vim.keymap.set({ 'n', 'x' }, '<c-cr>', ']]', { remap = true, buffer = true })
vim.keymap.set({ 'n', 'x' }, '<c-s-cr>', '[[', { remap = true })

-- LINKS
local url_re_str = vim.fn.escape(
  [[https?://(www\.)?[-a-zA-Z0-9@:%\._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}[-a-zA-Z0-9()@:%_+\.~#\?&/=;]*]], '?(){'
)
local url_re = vim.regex(url_re_str)
local url_re_precise = vim.regex(string.format('^%s$', url_re_str))

local function mdlink_extract_link(line, col)
  local mdlink_pat = '()%[.-%]%((.-)%)()'
  local iter = line:gmatch(mdlink_pat)
  while true do
    local mdlink_start, link, mdlink_end = iter()
    if not mdlink_start then
      return nil
    elseif mdlink_start <= col and col <= mdlink_end then
      return link
    end
  end
end

local function string_replace_range(text, replace_text, replace_first_byte, replace_last_byte)
  return string.format(
    '%s%s%s',
    string.sub(text, 0, replace_first_byte),
    replace_text,
    string.sub(text, replace_last_byte + 2)
  )
end

local function title_as_page_title(line, url, url_start, url_end)
  local url_for_curl = vim.fn.substitute(url, '^https://www.reddit.com/', 'https://old.reddit.com/', '')
  vim.fn.jobstart({ "curl", "-sL", url_for_curl }, {
    stdout_buffered = true,
    on_stdout = function(_, fetch_response)
      local parse_handle = vim.fn.jobstart({ "grep", "-oP", '(?<=<title>).*?(?=</title>)' },
        {
          stdout_buffered = true,
          on_stdout = function(_, parse_response)
            local title = parse_response[1]
            vim.schedule(function()
              vim.fn.setline(line,
                string_replace_range(vim.fn.getline(line), string.format('[%s](%s)', title, url),
                  url_start, url_end))
            end)
          end
        }
      )
      vim.fn.chansend(parse_handle, fetch_response)
      vim.fn.chanclose(parse_handle, "stdin")
    end
  })
end

--- @param line number
--- @param url string
--- @param url_start number
--- @param url_end number
local function title_as_url_shorthand(line, url, url_start, url_end)
  local domain, path = url:match("%a+://([^/]+).*(/[^/%?]+)")
  local title = domain .. path
  vim.schedule(function()
    vim.fn.setline(line,
      string_replace_range(vim.fn.getline(line), string.format('[%s](%s)', title, url),
        url_start, url_end))
  end)
end

local function mdlinkify(line_idx, col)
  local line = vim.fn.getline(line_idx)
  local search_start = 0
  while true do
    local url_start, url_end = url_re:match_line(vim.fn.bufnr(), line_idx - 1, search_start)
    if not url_start then -- file link
      local cfile = vim.fn.expand('<cfile>')
      if cfile == '' then break end
      local find_start = math.max(0, col - string.len(cfile))
      local cfile_first, cfile_last = line:find(cfile, find_start, true)
      if cfile_first > col then break end
      local path = cfile
      local ext = vim.fn.fnamemodify(path, ':e')
      local title = cfile
      if ext == '' and not vim.fn.filereadable(path) then
        path = path .. '.md'
      elseif ext == 'md' then
        title = path:gsub('.md$', '')
      else
      end
      vim.fn.setline(line_idx,
        string_replace_range(line, string.format('[%s](%s)', title, path),
          cfile_first - 1, cfile_last - 1))
      break
    else
      url_start = url_start + search_start
      url_end = url_end + search_start
      if url_start < col and col <= url_end then -- url link
        local url = string.sub(line, url_start + 1, url_end)
        title_as_url_shorthand(line_idx, url, url_start, url_end)
        break
      else
        search_start = search_start + url_end
      end
    end
  end
end

-- mdlink -> [text](link)
-- link   -> scheme://path?query#fragment | filename
local function link_action()
  local line = vim.fn.line('.')
  local line_str = vim.fn.getline(line)
  local col = vim.fn.col('.')
  local link = mdlink_extract_link(line_str, col)
  local root = os.getenv('WIKI') or vim.fn.expand('%:p:h')
  if link then
    if url_re_precise:match_str(link) or not string.match(io.popen('realpath ' .. link):read("a") or link, '^' .. root) then
      vim.ui.open(link)
    else
      vim.cmd('e ' .. link)
    end
  else
    mdlinkify(line, col)
  end
end

vim.keymap.set('n', '<cr>', link_action, { buffer = true })

-- EMBOLDENING & ITALICIZING
function make_surround_operator(surround_item)
  return function(type)
    -- Get the start and end positions of the motion
    local start_pos = vim.api.nvim_buf_get_mark(0, "[")
    local end_pos = vim.api.nvim_buf_get_mark(0, "]")

    -- 0-indexed rows for the API
    local start_row, start_col = start_pos[1] - 1, start_pos[2]
    local end_row, end_col = end_pos[1] - 1, end_pos[2]

    if type == 'line' then
      -- For whole lines, we wrap the entire line content
      local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
      for i, line in ipairs(lines) do
        lines[i] = surround_item .. line .. surround_item
      end
      vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, lines)
    else
      -- For character motions (w, e, f, etc.)
      -- end_col needs +1 because marks are inclusive and set_text is exclusive
      local text = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col + 1, {})
      if #text > 0 then
        text[1] = surround_item .. text[1]
        text[#text] = text[#text] .. surround_item
        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col + 1, text)
      end
    end
  end
end

local embolden_item = '**'
_G.embolden_operator = make_surround_operator('**')
vim.keymap.set('n', '<C-b>', function()
  vim.go.operatorfunc = 'v:lua.embolden_operator'
  return 'g@'
end, { expr = true, desc = 'Bold motion' })
vim.keymap.set('n', '<C-b><C-b>', function()
  vim.go.operatorfunc = 'v:lua.embolden_operator'
  return 'g@_'
end, { expr = true, desc = 'Bold current line' })
vim.keymap.set('v', '<C-b>', 'c' .. embolden_item .. '<C-r>"' .. embolden_item .. '<Esc>', { desc = 'Bold selection' })

local italicize_item = '_'
_G.italicize_operator = make_surround_operator(italicize_item)
vim.keymap.set('n', '<C-i>', function()
  vim.go.operatorfunc = 'v:lua.italicize_operator'
  return 'g@'
end, { expr = true, desc = 'Italicize motion' })
vim.keymap.set('n', '<C-i><C-i>', '0<C-i>$', { remap = true, desc = 'Italicize whole line' })
vim.keymap.set('v', '<C-i>', 'c' .. italicize_item .. '<C-r>"' .. italicize_item .. '<Esc>',
  { desc = 'Embolden selection' })
