vim.g.mapleader = " "

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 1
vim.opt.scrolloff = 5
vim.opt.clipboard = "unnamedplus"
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.mouse = "nvchr" -- mouse in all modes except insert

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }

map('n', '<Leader>cq', '<CMD>cclose<cr>', opt)
map('n', '<Leader>cj', '<CMD>cnext<cr>', opt)
map('n', '<Leader>ck', '<CMD>cprev<cr>', opt)

require('maxconf.colorscheme')
require('maxconf.lualine')
require('maxconf.telescope')
require('maxconf.treesitter')
require('maxconf.nvim-tree')
require('maxconf.lsp')
require('maxconf.easy-align')
require('maxconf.gitsigns')
