require("neo-tree").setup({
  window = {
    position = "right",
    mappings = {
      ["l"] = "open_node",
      ["h"] = "close_node",
    },
  },
})

vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>")
vim.keymap.set("n", "g<C-n>", ":Neotree toggle git_status<CR>")
