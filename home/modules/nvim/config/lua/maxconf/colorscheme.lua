local default_colors = require("kanagawa.colors").setup()

local overrides = {
  -- make the indent line of the current context a gray-ish color
  IndentBlanklineContextChar = { link = "IndentBlanklineChar" },
  TrailingWhitespace = { link = "DiffDelete" },
}

require("kanagawa").setup({
  overrides = overrides,
})

vim.cmd("colorscheme kanagawa")
vim.cmd("match TrailingWhitespace /\\s\\+$/")
