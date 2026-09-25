local git_roots = {}
local git_projects_root_hl_data = {}
local git_project_hl_i = 1
local graphite = "#A89984"
local black = "#000000"
local hl_datas = {
  { "TabLineGitProject1", "#009FfF", },
  { "TabLineGitProject3", "#eFc700", },
  { "TabLineGitProject4", "#fF4f6A", },
  { "TabLineGitProject6", "#4FcF4F", },
  { "TabLineGitProject5", "#a460cF", },
}
vim.api.nvim_set_hl(0, "TabLineNonGitSel", { bg = graphite, fg = black })
vim.api.nvim_set_hl(0, "TabLineNonGit", { fg = graphite })

local function git_project_hl_set(hl_group, color)
  vim.api.nvim_set_hl(0, hl_group .. "Sel", { bg = color, fg = black })
  vim.api.nvim_set_hl(0, hl_group, { fg = color })
end

local function get_git_project_hl_group(git_root, selected)
  local project_hl_data = git_projects_root_hl_data[git_root]
  if project_hl_data == nil then
    local hl_data = hl_datas[git_project_hl_i]
    git_project_hl_i = git_project_hl_i % #hl_datas + 1
    -- INFO: Setting a highlight can invalidate the tabline and re-enter this function. Cache the assignment before changing the highlight so a re-render cannot assign the same project a different group.
    project_hl_data = hl_data
    git_projects_root_hl_data[git_root] = project_hl_data

    git_project_hl_set(hl_data[1], hl_data[2]) -- lazy initialization
  end
  return "%#" .. project_hl_data[1] .. (selected and "Sel" or "") .. "#"
end

local function take_suffix(value, max_width)
  local suffix = ""
  for char_i = vim.fn.strchars(value) - 1, 0, -1 do
    local char = vim.fn.strcharpart(value, char_i, 1)
    local candidate = char .. suffix
    if vim.fn.strdisplaywidth(candidate) > max_width then break end
    suffix = candidate
  end
  return suffix
end

local function fit_tab_name(tab_i, name, max_width)
  local prefix = tab_i .. ":"
  local name_width = max_width - vim.fn.strdisplaywidth(prefix)
  if name_width <= 0 then return prefix end
  if vim.fn.strdisplaywidth(name) <= name_width then return prefix .. name end

  -- Keep the tab number visible and remove characters from the start of its name.
  local dot_count = math.min(2, math.max(1, name_width - 1))
  local dots = string.rep(".", dot_count)
  return prefix .. dots .. take_suffix(name, name_width - dot_count)
end

local function get_tab_name(tab_i, max_width)
  -- local res = tab_i .. ":"
  local bufname = vim.fn.bufname(vim.fn.tabpagebuflist(tab_i)[vim.fn.tabpagewinnr(tab_i)])
  local selected = tab_i == vim.fn.tabpagenr()
  if bufname == "" then
    local group = selected and "%#TabLineGitProject0Sel#" or "%#TabLineGitProject0#"
    return group .. fit_tab_name(tab_i, "[Empty]", max_width)
  end

  local file_path = vim.fn.fnamemodify(bufname, ":p")
  local dir_path = vim.fn.fnamemodify(file_path, ":h")
  local git_root = git_roots[dir_path]
  if git_root == nil then
    git_root = vim.fn.systemlist({ "git", "-C", dir_path, "rev-parse", "--show-toplevel" })[1] or false
    if vim.v.shell_error ~= 0 then git_root = false end
    git_roots[dir_path] = git_root
  end

  local folder_name = vim.fn.fnamemodify(file_path, ":h:t")
  local file_name = vim.fn.fnamemodify(file_path, ":t")
  local tab_name = folder_name .. "/" .. file_name
  if git_root then
    local group = get_git_project_hl_group(git_root, selected)
    local relative_name = vim.fs.relpath(git_root, file_path) or tab_name
    return group .. fit_tab_name(tab_i, relative_name, max_width)
  end
  local group = selected and "%#TabLineNonGitSel#" or "%#TabLineNonGit#"
  return group .. fit_tab_name(tab_i, tab_name, max_width)
end

function MyTabLine()
  local res = ""
  local tab_count = vim.fn.tabpagenr("$")
  local separator_width = math.max(0, tab_count - 1)
  local max_tab_width = math.floor(math.max(0, vim.o.columns - separator_width) / tab_count)
  for tab_i = 1, tab_count do
    if tab_i ~= 1 then
      res = res .. "%#Sep#|"
    end
    res = res .. get_tab_name(tab_i, max_tab_width)
  end
  res = res .. "%#TabLineFill#%T"
  return res
end
