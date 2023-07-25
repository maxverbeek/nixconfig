require("diffview").setup({
  merge_tool = {
    layout = "diff3_mixed",
  },
})

vim.cmd([[
cabbrev DVO DiffviewOpen
cabbrev DVC DiffviewClose
]])
