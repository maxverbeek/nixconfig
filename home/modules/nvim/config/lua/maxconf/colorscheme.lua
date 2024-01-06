vim.cmd("colorscheme kanagawa")

local default_colors = require("kanagawa.colors").setup()
local overrides = {
  -- make the indent line of the current context a gray-ish color
  -- IndentBlanklineContextChar = { link = "IndentBlanklineChar" },
  IblScope = { link = "IblIndent" },

  TrailingWhitespace = { link = "DiffDelete" },
}

require("kanagawa").setup({
  overrides = overrides,
})
