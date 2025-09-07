vim.loader.enable()

vim.cmd("colorscheme kanagawa")

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.winborder = "rounded"

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

-- lsp keymaps
local snacks = require("snacks")

vim.keymap.set("n", "gd", snacks.picker.lsp_definitions)
vim.keymap.set("n", "gr", snacks.picker.lsp_references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)

vim.keymap.set("n", "g[", vim.diagnostic.goto_prev)
vim.keymap.set("n", "g]", vim.diagnostic.goto_next)

-- file browse keymaps
vim.keymap.set("n", "<C-p>", function()
  snacks.picker.files({ cmd = "rg" })
end)
