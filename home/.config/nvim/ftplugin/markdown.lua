local rb = { remap = true, buffer = 0 }
-- Italics
vim.keymap.set('n', '<localleader>c', 'mmysiW*`m', rb)
vim.keymap.set('x', '<localleader>c', 'mms*`m', rb)
-- Bold
vim.keymap.set('n', '<localleader>b', 'mmysiW*v`]o`[s*`m', rb)
vim.keymap.set('x', '<localleader>b', 'mms*v`]o`[s*`m', rb)

local url_re_str = vim.fn.escape(
  [[https?://(www\.)?[-a-zA-Z0-9@:%\._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}[-a-zA-Z0-9()@:%_+\.~#\?&/=;]*]], '?(){'
)
local url_re = vim.regex(url_re_str)
local url_re_precise = vim.regex(string.format('^%s$', url_re_str))

local function root_get()
  local dir = vim.fn.expand('%:p:h')
  while true do
    local file = io.open(dir .. '/index.md', 'r')
    if file ~= nil and file:close() then return dir end
    if dir == os.getenv('HOME') then return dir end
    dir = dir:match("(.*)/")
  end
end
local root = root_get()
print(root)

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
      -- local path = io.popen('realpath ' .. cfile):read()
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
        local url_for_curl = vim.fn.substitute(url, '^https://www.reddit.com/', 'https://old.reddit.com/', '')
        local line, url, url_start, url_end = line_idx, url, url_start, url_end
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
        break
      else
        search_start = search_start + url_end
      end
    end
  end
end

-- TODO
-- mdlink -> [text](link)
-- link   -> scheme://path?query#fragment | filename
local function link_action()
  local line = vim.fn.line('.')
  local line_str = vim.fn.getline(line)
  local col = vim.fn.col('.')
  local link = mdlink_extract_link(line_str, col)
  if link then
    if url_re_precise:match_str(link) or not string.match(link, '^' .. root) then
      vim.ui.open(link)
    else
      vim.cmd('tabe ' .. link)
    end
  else
    mdlinkify(line, col)
  end
end

vim.keymap.set('n', '<cr>', link_action, { buffer = true })
