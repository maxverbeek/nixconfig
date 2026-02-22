local snacks = require("snacks")

snacks.setup({
  picker = {
    enabled = true,
    sources = {
      explorer = {
        auto_close = true,
        layout = { layout = { position = "right" } },
      },
    },
  },
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
})
