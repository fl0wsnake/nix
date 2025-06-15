silent={silent=true}

vim.o.fileencoding = 'utf-8'
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.cmd([[
  set termguicolors
  set autochdir
  set expandtab shiftwidth=2
  set number relativenumber 
  set smartcase nowrapscan 
  set scrolloff=999 sidescrolloff=20 
  set clipboard+=unnamedplus autowrite autowriteall
]])

-- Tabs
vim.keymap.set('', '<C-t>', function() vim.cmd'tabnew' end, silent)
vim.api.nvim_set_keymap('', '<C-l>', 'gt', silent)
vim.api.nvim_set_keymap('', '<C-h>', 'gT', silent)
vim.api.nvim_set_keymap('', '<C-1>', '1gt', silent)
vim.api.nvim_set_keymap('', '<C-2>', '2gt', silent)
vim.api.nvim_set_keymap('', '<C-3>', '3gt', silent)
vim.api.nvim_set_keymap('', '<C-4>', '4gt', silent)
vim.api.nvim_set_keymap('', '<C-5>', '5gt', silent)
vim.api.nvim_set_keymap('', '<C-6>', '6gt', silent)
vim.api.nvim_set_keymap('', '<C-7>', '7gt', silent)
vim.api.nvim_set_keymap('', '<C-8>', '8gt', silent)
vim.api.nvim_set_keymap('', '<C-9>', '9gt', silent)
vim.api.nvim_set_keymap('', '<C-1>', '1gt', silent)
vim.api.nvim_set_keymap('', '<C-2>', '2gt', silent)

-- Commands
-- vim.g.MY_WIKI = os.getenv'MY_WIKI'
-- vim.cmd('command! Wiki lua vim.cmd("e " .. os.getenv'MY_WIKI' .. "/index.md")')
vim.cmd('command! Wiki e $MY_WIKI/index.md')

-- Bookmarks
vim.keymap.set('', '<leader>br', function() vim.cmd('e ~/.config/nix') end, silent)
vim.keymap.set("n", "<leader>bw", function() vim.cmd('Wiki') end, Silent)

