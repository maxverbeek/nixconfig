vim.loader.enable()

vim.cmd("colorscheme kanagawa")

vim.g.c_syntax_for_h = 1
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.winborder = "rounded"
vim.opt.laststatus = 2
vim.opt.scrolloff = 5
vim.opt.clipboard = "unnamedplus"
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.mouse = "nvchr" -- mouse in all modes except insert

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.title = true

-- Set update time for cursorhold autocommand
vim.o.updatetime = 300

vim.lsp.enable({
  "arduino_language_server",
  "clangd",
  "elixirls",
  "gopls",
  "hls",
  "metals",
  "nil_ls",
  "ocamllsp",
  "pyright",
  "rust_analyzer",
  "solargraph",
  "svelte",
  "tailwindcss",
  "terraformls",
  "texlab",
  "ts_ls",
})

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
})

-- lsp keymaps
local snacks = require("snacks")

vim.keymap.set("n", "gd", snacks.picker.lsp_definitions)
vim.keymap.set("n", "gr", snacks.picker.lsp_references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)

vim.keymap.set("n", "g[", vim.diagnostic.goto_prev)
vim.keymap.set("n", "g]", vim.diagnostic.goto_next)

-- file browse keymaps
vim.keymap.set("n", "<Leader>ff", function()
  snacks.picker.files({ cmd = "rg" })
end)

vim.keymap.set("n", "<Leader>fg", function()
  snacks.picker.grep({ cmd = "rg" })
end)

vim.keymap.set("n", "<Leader>fh", snacks.picker.help)
vim.keymap.set("n", "<Leader>fq", snacks.picker.qflist)
vim.keymap.set("n", "<C-n>", snacks.explorer.reveal)
vim.keymap.set("x", "<Leader>gb", snacks.gitbrowse.open)

-- base64 encode & decode with leader64 and leader46
vim.keymap.set("v", "<leader>64", "c<c-r>=system('base64 --wrap 0', @\")<cr><esc>")
vim.keymap.set("v", "<leader>46", "c<c-r>=system('base64 --decode', @\")<cr><esc>")

-- when searching, center the result
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- move code around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- yank to eol like D
vim.keymap.set("n", "Y", "yg$")
