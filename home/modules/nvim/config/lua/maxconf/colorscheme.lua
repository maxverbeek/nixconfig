local default_colors = require('kanagawa.colors').setup()

local overrides = {
  -- make the indent line of the current context a gray-ish color
  IndentBlanklineContextChar = { link = "IndentBlanklineChar" }
}

require('kanagawa').setup({
  overrides = overrides
})

vim.cmd("colorscheme kanagawa")
