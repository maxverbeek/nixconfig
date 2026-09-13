vim.keymap.set("n", "]]", function()
  require("notebook-navigator").move_cell("d")
end)
vim.keymap.set("n", "[[", function()
  require("notebook-navigator").move_cell("u")
end)

vim.keymap.set("n", "<leader>ee", require("notebook-navigator").run_cell)
vim.keymap.set("n", "<leader>en", require("notebook-navigator").run_and_move)
