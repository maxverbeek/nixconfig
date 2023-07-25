require("diffview").setup({
  merge_tool = {
    layout = "diff3_mixed",
  },
})

vim.cmd([[
abbreviate DVO DiffviewOpen
abbreviate DVC DiffviewClose
]])
