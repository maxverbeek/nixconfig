vim.g.mapleader = " "

vim.g.c_syntax_for_h = 1

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 2
vim.opt.scrolloff = 5
vim.opt.clipboard = "unnamedplus"
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.mouse = "nvchr" -- mouse in all modes except insert
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.window = true

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }

map("n", "<Leader>cq", "<CMD>cclose<cr>", opt)
map("n", "<C-j>", "<CMD>cnext<cr>", opt)
map("n", "<C-k>", "<CMD>cprev<cr>", opt)
map("n", "n", "nzzzv", opt)
map("n", "N", "Nzzzv", opt)

-- move code around
map("v", "J", ":m '>+1<CR>gv=gv", opt)
map("v", "K", ":m '<-2<CR>gv=gv", opt)

-- yank to eol like D
map("n", "Y", "yg$", opt)

map("n", "<leader>d", '"_d', opt)
map("v", "<leader>d", '"_d', opt)

map("t", "<Esc><Esc>", "<C-\\><C-N>", opt)

-- base64 encode & decode with leader64 and leader46
map("v", "<leader>64", "c<c-r>=system('base64 --wrap 0', @\")<cr><esc>", opt)
map("v", "<leader>46", "c<c-r>=system('base64 --decode', @\")<cr><esc>", opt)
