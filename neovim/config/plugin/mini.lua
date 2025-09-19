require("mini.ai").setup()
require("mini.align").setup({
  mappings = {
    start = "<Leader>ga",
    start_with_preview = "<Leader>gA",
  },
})
require("mini.comment").setup({})
require("mini.diff").setup({})
require("mini.pairs").setup({})
require("mini.surround").setup({})
require("mini.statusline").setup({})
