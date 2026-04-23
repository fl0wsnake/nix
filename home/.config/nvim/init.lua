require("config.util")
Silent = { silent = true }
_ = {}
vim.api.nvim_create_augroup('my', { clear = false })

-- vim.cmd('set guicursor=a:Cursor')
-- vim.cmd('highlight Cursor gui=NONE guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE')
vim.cmd([[
  highlight Cursor guibg=#00FF00 guifg=NONE
  highlight iCursor guibg=#00FF00 guifg=NONE
  highlight vCursor guibg=#00FF00 guifg=NONE
  highlight rCursor guibg=#00FF00 guifg=NONE
]])

-- vim.cmd('highlight Cursor guibg=white')

vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.g.mapleader = " "
vim.g.maplocalleader = ","

--- PROCESS INTEGRATION
vim.cmd('set termguicolors title titlestring=%t')
--- FILESYSTEM
vim.api.nvim_create_autocmd(
  { "BufWritePre" },
  {
    callback = function()
      if vim.o.ft ~= 'oil' then
        local dirname = vim.fn.expand('%:p:h')
        if vim.fn.filereadable(dirname) == 0 then vim.fn.system('mkdir -p ' .. dirname) end
      end
    end
  })
vim.cmd('set noswapfile autochdir clipboard+=unnamedplus autowrite autowriteall')
vim.keymap.set("", "<leader>e", function() vim.cmd.file(io.popen('readlink -f ' .. vim.fn.expand('%')):read()) end,
  Silent)
vim.keymap.set("", "<leader>y",
  function()
    vim.fn.system(string.format("wl-copy '%s'",
      vim.fn.substitute(vim.fn.expand('%:p'), os.getenv("HOME"), '~', '')))
  end,
  Silent)
vim.keymap.set("", "<leader>p", function() vim.cmd('e ' .. vim.fn.getreg('+')) end)
vim.keymap.set("", "<c-s>", function() if vim.o.ft == 'oil' then vim.cmd('w') else vim.cmd('sil! wa') end end)
vim.keymap.set({ "", 'i' }, "<C-q>", function() vim.cmd('q') end)
vim.keymap.set({ "", 'i' }, "<C-S-q>", function() vim.cmd('tabclose') end)
vim.api.nvim_create_autocmd({ "FocusLost" }, {
  pattern = '*', callback = function() if vim.o.ft ~= 'oil' then vim.cmd('sil! wa') end end, nested = true
})
vim.keymap.set("", "<leader>x", function()
  io.popen("sudo chmod +x " .. vim.fn.expand('%'))
  vim.o.filetype = 'sh'
  if vim.fn.getline(1) ~= '#!/usr/bin/env bash' then
    vim.cmd("1s~^~#!/usr/bin/env bash\r\r")
    vim.fn.setreg("/", "")
  end
end)

--- STATUSLINE
function _G.git_relative_path()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then return '[No Name]' end
  local git_root = vim.fn.systemlist('git -C ' ..
    vim.fn.shellescape(vim.fn.fnamemodify(filepath, ':h')) .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 or not git_root then
    return vim.fn.expand('%:t')
  end
  local root_dirname = vim.fn.fnamemodify(git_root, ':t')
  local relative = filepath:sub(#git_root + 2) -- strip git_root + trailing slash
  if relative == '' then
    return root_dirname
  end
  return '%#StatusLineBold#' .. root_dirname .. '%#StatusLine#/' .. relative
end

vim.api.nvim_set_hl(0, 'StatusLineBold', { bold = true, italic = true })
vim.o.statusline = '%{%v:lua.git_relative_path()%} %h%m%r %L %c%V'

--- TYPING
vim.keymap.set('v', '$', 'g_')
vim.keymap.set({ "", "i" }, "<c-c>", '<esc>')
vim.keymap.set("", "j", 'gj')
vim.keymap.set("", "k", 'gk')
vim.keymap.set("", "<c-d>", function() vim.cmd('normal ' .. vim.o.scroll .. 'gj') end) -- keep expected behavior when wrap
vim.keymap.set("", "<c-u>", function() vim.cmd('normal ' .. vim.o.scroll .. 'gk') end)

--- INTERFACE
vim.opt.mouse = ''

--- SEARCH
vim.cmd('set ignorecase smartcase')
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", { expr = true }) -- n searches forward regardless of / or ?
vim.keymap.set("n", "N", "'nN'[v:searchforward]", { expr = true }) -- N searches backward regardless of / or ?

--- SELECTION
vim.keymap.set("n", "<a-v>", "`[v`]") -- Pasted or yanked text
vim.keymap.set("n", "<a-V>", "ggVG")  -- All text

-- TOGGLES
vim.keymap.set("", "<a-w>", function()
  vim.cmd('set wrap!')
  print("wrap == " .. tostring(vim.o.wrap))
end)

--- DISABLE AUTOCOMMETING NEXT LINE
vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = "*",
    command = 'set formatoptions-=ro'
  }
)

--- EDITING
vim.cmd('set number relativenumber diffopt+=vertical')
vim.cmd('set cindent')  -- Format .nix files same as `=`
vim.cmd('set tabstop=2 expandtab shiftwidth=2')
vim.cmd('set nofixeol') -- Automatic newline before eol messes git diffs and specific file requirements

-- COMMENTING
vim.api.nvim_set_keymap('n', 'z', 'gc', _)
vim.api.nvim_set_keymap('n', 'zz', 'gcgc', _)
vim.api.nvim_set_keymap('x', 'z', 'gc', _)

-- -- AUTOFORMATTING -- XXX: breaks Xpaste mapped to Easyclip despite `remap = true`
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = '*',
--   callback = function()
--     if vim.o.ft ~= '' and vim.o.ft ~= 'text' and vim.o.ft ~= 'markdown' then
--       vim.keymap.set("n", "p", "p`]=`[", { remap = true, silent = true })
--       vim.keymap.set("v", "p", "p`]=`[", { remap = true, silent = true })
--     end
--   end
-- })

--- TABLES
vim.keymap.set("v", "<leader>t", ":'<,'>!column -t -s'|' -o'|'<cr>")
vim.keymap.set("n", "<leader>t", "vip:'<,'>!column -t -s'|' -o'|'<cr>")

--- SORTING
vim.keymap.set("v", "<a-s>", ":'<,'>!sort<cr>")
vim.keymap.set("n", "<a-s>", Sort_paragraph())
vim.keymap.set("v", "<a-s-s>", ":'<,'>!sort -r<cr>")
vim.keymap.set("n", "<a-s-s>", Sort_paragraph(true))

--- MOVING AROUND
vim.keymap.set("n", "<a-j>", ":m .+1<cr>")
vim.keymap.set("i", "<a-j>", "<esc>:m .+1<cr>==gi")
vim.keymap.set("v", "<a-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("n", "<a-k>", ":m .-2<cr>")
vim.keymap.set("i", "<a-k>", "<esc>:m .-2<cr>==gi")
vim.keymap.set("v", "<a-k>", ":m '<-2<cr>gv=gv")
vim.keymap.set("", "<a-h>", Up_v)
vim.keymap.set("", "<a-l>", Down_v)

--- PRESENTATION
vim.o.list = true
vim.o.listchars = 'tab:  ,precedes:❮,extends:❯,trail:·,nbsp:…'
vim.cmd('set cursorline nowrap scrolloff=999 sidescrolloff=10')
vim.api.nvim_create_autocmd("VimResized", {
  pattern = '*', command = "wincmd ="
})
vim.api.nvim_create_autocmd("BufReadPost", { -- Jump to last visited pos per file
  pattern = '*',
  callback = function()
    if vim.fn.line('\'"') > 0 and vim.fn.line('\'"') < vim.fn.line('$') then
      vim.cmd('norm! g`"')
    end
  end
})
vim.api.nvim_create_autocmd("BufEnter", { -- Uniquely distunguish [No Name] buffers for selection via `ft`
  pattern = "*",
  callback = function()
    if vim.fn.expand("%") == "" then
      vim.bo.ft = "nofile" -- Custom unique filetype
    end
  end,
})


--- TABS
vim.keymap.set({ '', 'i' }, '<C-t>', '<cmd>tab split<cr>')
vim.keymap.set({ '', 'i' }, '<C-S-t>', '<cmd>tabe<cr>')
vim.keymap.set({ '', 'i' }, '<C-S-PageUp>', function() vim.cmd '-tabm' end)
vim.keymap.set({ '', 'i' }, '<C-S-PageDown>', function() vim.cmd '+tabm' end)
vim.keymap.set({ '', 'i' }, '<C-Tab>', function() vim.cmd 'tabn' end)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = 'fzf',
  callback = function()
    vim.keymap.set({ '', 'i' }, '<C-Tab>', function() vim.cmd 'tabn' end)
  end
})
vim.keymap.set({ '', 'i' }, '<C-S-Tab>', function() vim.cmd 'tabp' end)
vim.api.nvim_set_keymap('', '<C-h>', '<C-w>h', _)
vim.api.nvim_set_keymap('', '<C-j>', '<C-w>j', _)
vim.api.nvim_set_keymap('', '<C-k>', '<C-w>k', _)
vim.api.nvim_set_keymap('', '<C-l>', '<C-w>l', _)
vim.api.nvim_set_keymap('', '<C-1>', '1gt', _)
vim.api.nvim_set_keymap('', '<C-2>', '2gt', _)
vim.api.nvim_set_keymap('', '<C-3>', '3gt', _)
vim.api.nvim_set_keymap('', '<C-4>', '4gt', _)
vim.api.nvim_set_keymap('', '<C-5>', '5gt', _)
vim.api.nvim_set_keymap('', '<C-6>', '6gt', _)
vim.api.nvim_set_keymap('', '<C-7>', '7gt', _)
vim.api.nvim_set_keymap('', '<C-8>', '8gt', _)
vim.api.nvim_set_keymap('', '<C-9>', '<cmd>tabl<cr>', _)

--- CMD ABBREVIATIONS
vim.cmd("command! -nargs=1 -complete=help H h <args> | on")
vim.cmd("cnoreabbrev <expr> h (getcmdtype() == ':' && getcmdline()=~'^h' ? 'H' : 'h')")
vim.cmd("cnoreabbrev <expr> m (getcmdtype() == ':' && getcmdline()=~'^m' ? 'Man' : 'm')")
vim.api.nvim_create_autocmd("FileType", { pattern = "man", callback = function() vim.cmd('on') end })

--- BOOKMARKS
vim.cmd('command! Wiki e $WIKI/index.md')
vim.keymap.set('', "<leader>bN", function() vim.cmd('e ~/.config/nnn/config') end)
vim.keymap.set('', "<leader>bW", function() vim.cmd('e ~/WS') end)
vim.keymap.set('', "<leader>bd", function() vim.cmd('e $RICE/nixos/configuration.nix') end)
vim.keymap.set('', "<leader>bn", function() vim.cmd('e ~/.config/nvim/init.lua') end)
vim.keymap.set('', "<leader>bs", function() vim.cmd('e ~/.config/sway/config') end)
vim.keymap.set('', "<leader>bw", function() vim.cmd('Wiki') end)
vim.keymap.set('', "<leader>bz", function() vim.cmd('e ~/.cache/zig/.index') end)
vim.keymap.set('', '<leader>bl', function() vim.cmd('e ~/.local/share/nvim/lazy') end)
vim.keymap.set('', '<leader>bp', function() vim.cmd('e ~/.profile') end)
vim.keymap.set('', '<leader>l',
  -- function() vim.cmd('h lspconfig-all | on | tabe | exe "e" stdpath("data") .. "/lazy/none-ls.nvim/doc/BUILTINS.md"') end,
  function() vim.cmd('h lspconfig-all | on') end,
  Silent)

--- SESSION
vim.cmd('se shortmess+=Ac') -- disable prompt on launch with -S option
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for arg_i, arg in pairs(vim.v.argv) do
      if arg == '-S' then
        vim.cmd("mksession! " .. vim.v.argv[arg_i + 1])
      end
    end
  end,
})

require("config.lazy")
