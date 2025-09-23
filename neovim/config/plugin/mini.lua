require("mini.ai").setup()
require("mini.align").setup({
  mappings = {
    start = "<Leader>ga",
    start_with_preview = "<Leader>gA",
  },
})

require("mini.comment").setup({
  options = {
    custom_commentstring = function()
      return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
    end,
  },
})

require("mini.diff").setup({})
require("mini.pairs").setup({})
require("mini.surround").setup({})
require("mini.statusline").setup({})
