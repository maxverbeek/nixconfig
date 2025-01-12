require("neo-tree").setup({
  window = {
    position = "right",
  },
})

vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>")
vim.keymap.set("n", "g<C-n>", ":Neotree toggle git_status<CR>")
