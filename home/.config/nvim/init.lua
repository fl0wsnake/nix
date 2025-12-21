require("config.utils")
Silent = { silent = true }
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
-- vim.o.statusline = '%<%{v:lua.MyStatus()} %m%r%=%l,%L'
-- vim.g.netrw_list_hide = '\\.\\./,\\./' # TODO: remove
-- vim.keymap.set("", "<A-x>", function() vim.cmd('Ex') end, Silent)
-- vim.g.netrw_banner = 0
vim.keymap.set("", "<leader>e", function() vim.cmd.file(io.popen('readlink -f ' .. vim.fn.expand('%')):read()) end,
  Silent)
vim.keymap.set("", "<leader>y",
  function()
    vim.fn.system(string.format("wl-copy '%s'",
      vim.fn.substitute(vim.fn.expand('%:p'), os.getenv("HOME"), '~', '')))
  end,
  Silent)
vim.keymap.set("", "<leader>p", function() vim.cmd('e ' .. vim.fn.getreg('+')) end, Silent)
vim.keymap.set("", "<c-s>", function() if vim.o.ft == 'oil' then vim.cmd('w') else vim.cmd('sil! wa') end end, Silent)
vim.keymap.set({ "", 'i' }, "<C-q>", function() vim.cmd('q') end, Silent)
vim.keymap.set({ "", 'i' }, "<C-S-q>", function() vim.cmd('tabclose') end, Silent)
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
end, Silent)

--- TYPING
vim.keymap.set({ "", "i" }, "<c-c>", '<esc>', Silent)
vim.keymap.set("", "j", 'gj', Silent)
vim.keymap.set("", "k", 'gk', Silent)
vim.keymap.set("", "<c-d>", function() vim.cmd('normal ' .. vim.o.scroll .. 'gj') end, Silent)
vim.keymap.set("", "<c-u>", function() vim.cmd('normal ' .. vim.o.scroll .. 'gk') end, Silent)

--- DISABLE MOUSE
vim.opt.mouse = ''
-- vim.keymap.set({ 'n', 'i' }, '<Up>', '<nop>') TODO remove idk why its here
-- vim.keymap.set({ 'n', 'i' }, '<Down>', '<nop>')
-- vim.keymap.set({ 'n', 'i' }, '<Left>', '<nop>')
-- vim.keymap.set({ 'n', 'i' }, '<Right>', '<nop>')

--- SEARCH
vim.cmd('set ignorecase smartcase')
vim.keymap.set("", "<leader>/", function() vim.fn.setreg("/", "") end, Silent)

--- SELECTION
vim.keymap.set("n", "<a-v>", "`[v`]") -- Pasted or yanked text
vim.keymap.set("n", "<a-V>", "ggVG")  -- All text

-- TOGGLES
vim.keymap.set("", "<a-w>", function()
  vim.cmd('set wrap!')
  print("wrap == " .. tostring(vim.o.wrap))
end, Silent)

--- DISABLE AUTOCOMMETING NEXT LINE
vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = "*",
    command = 'set formatoptions-=ro'
  }
)

--- EDITING
vim.cmd('set cindent') -- Format .nix files same as `=`
vim.cmd('set tabstop=2 expandtab shiftwidth=2')

-- COMMENTING
vim.api.nvim_set_keymap('n', 'z', 'gc', {})
vim.api.nvim_set_keymap('n', 'zz', 'gcgc', {})

-- AUTO FORMATTING
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = '*',
  callback = function()
    if vim.o.ft ~= '' and vim.o.ft ~= 'text' and vim.o.ft ~= 'markdown' then
      vim.keymap.set("n", "p", "p`]=`[", { noremap = true, silent = true })
      vim.keymap.set("v", "p", "p`]=`[", { noremap = true, silent = true })
    end
  end
})

--- LINE SWAPPING
vim.keymap.set("n", "<a-j>", ":m .+1<cr>", Silent)
vim.keymap.set("i", "<a-j>", "<esc>:m .+1<cr>==gi", Silent)
vim.keymap.set("v", "<a-j>", ":m '>+1<cr>gv=gv", Silent)
vim.keymap.set("n", "<a-k>", ":m .-2<cr>", Silent)
vim.keymap.set("i", "<a-k>", "<esc>:m .-2<cr>==gi", Silent)
vim.keymap.set("v", "<a-k>", ":m '<-2<cr>gv=gv", Silent)

--- TABLES
vim.keymap.set("v", "<leader>t", ":'<,'>!column -t -s'|' -o'|'<cr>", Silent)
vim.keymap.set("n", "<leader>t", "vip:'<,'>!column -t -s'|' -o'|'<cr>", Silent)

--- SORTING
vim.keymap.set("v", "<a-t>", ":'<,'>!sort<cr>", Silent)
vim.keymap.set("n", "<a-t>", "vip:'<,'>!sort<cr>", Silent)
vim.keymap.set("v", "<a-s-t>", ":'<,'>!sort -r<cr>", Silent)
vim.keymap.set("n", "<a-s-t>", "vip:'<,'>!sort -r<cr>", Silent)

--- MOVING AROUND
vim.keymap.set("", "<c-j>", Down_v, Silent)
vim.keymap.set("", "<c-k>", Up_v, Silent)

--- PRESENTATION
vim.o.list = true
vim.o.listchars = 'tab:▸ ,precedes:❮,extends:❯,trail:·,nbsp:…'
-- TODO removing number relativenumber
vim.cmd('set nowrap scrolloff=999 sidescrolloff=10')
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


--- WINDOW MANAGEMENT
vim.keymap.set('', '<A-h>', '<C-w>h', Silent)
vim.keymap.set('', '<A-l>', '<C-w>l', Silent)

--- TABS
vim.keymap.set({ '', 'i' }, '<C-t>', '<cmd>tabe % | normal! zz<cr>', Silent)
vim.keymap.set({ '', 'i' }, '<C-S-PageUp>', function() vim.cmd '-tabm' end, Silent)
vim.keymap.set({ '', 'i' }, '<C-S-PageDown>', function() vim.cmd '+tabm' end, Silent)
vim.keymap.set({ '', 'i' }, '<C-Tab>', function() vim.cmd 'tabn' end, Silent)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = 'fzf',
  callback = function()
    vim.keymap.set({ '', 'i' }, '<C-Tab>', function() vim.cmd 'tabn' end, Silent)
  end
})
vim.keymap.set({ '', 'i' }, '<C-S-Tab>', function() vim.cmd 'tabp' end, Silent)
vim.api.nvim_set_keymap('', '<C-l>', '<C-w>l', Silent)
vim.api.nvim_set_keymap('', '<C-h>', '<C-w>h', Silent)
vim.api.nvim_set_keymap('', '<C-1>', '1gt', Silent)
vim.api.nvim_set_keymap('', '<C-2>', '2gt', Silent)
vim.api.nvim_set_keymap('', '<C-3>', '3gt', Silent)
vim.api.nvim_set_keymap('', '<C-4>', '4gt', Silent)
vim.api.nvim_set_keymap('', '<C-5>', '5gt', Silent)
vim.api.nvim_set_keymap('', '<C-6>', '6gt', Silent)
vim.api.nvim_set_keymap('', '<C-7>', '7gt', Silent)
vim.api.nvim_set_keymap('', '<C-8>', '8gt', Silent)
vim.api.nvim_set_keymap('', '<C-9>', '9gt', Silent)

--- CMD ABBREVIATIONS
vim.cmd("command! -nargs=1 -complete=help H h <args> | on")
vim.cmd("cnoreabbrev <expr> h (getcmdtype() == ':' && getcmdline()=~'^h' ? 'H' : 'h')")
vim.cmd("cnoreabbrev <expr> m (getcmdtype() == ':' && getcmdline()=~'^m' ? 'Man' : 'm')")
vim.api.nvim_create_autocmd("FileType", { pattern = "man", callback = function() vim.cmd('on') end })

--- BOOKMARKS
vim.cmd('command! Wiki e $WIKI/index.md') -- for external use
vim.keymap.set('', "<leader>bn", function() vim.cmd('e ~/.config/nvim/init.lua') end, Silent)
vim.keymap.set('', "<leader>bz", function() vim.cmd('e $ZDOTDIR/.zshrc') end, Silent)
vim.keymap.set('', "<leader>bd", function() vim.cmd('e $RICE/nixos/configuration.nix') end, Silent)
vim.keymap.set('', '<leader>bp', function() vim.cmd('e ~/.local/share/nvim/lazy') end, Silent)
vim.keymap.set('', "<leader>bw", function() vim.cmd('Wiki') end, Silent)
vim.keymap.set('', "<leader>bs", function() vim.cmd('e ~/WS') end, Silent)
vim.keymap.set('', '<leader>l',
  function() vim.cmd('h lspconfig-all | on | tabe | exe "e" stdpath("data") .. "/lazy/none-ls.nvim/doc/BUILTINS.md"') end,
  Silent)

--- SESSION
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, el in vim.v.argv do
      if el == '-S' then
        vim.cmd("mksession! " .. os.getenv("NVIM_SESSION"))
      end
    end
  end,
})

require("config.lazy")
