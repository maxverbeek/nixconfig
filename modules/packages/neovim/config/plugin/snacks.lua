local snacks = require("snacks")

snacks.setup({
  picker = {
    enabled = true,
    sources = {
      explorer = {
        auto_close = true,
        hidden = true,
        ignored = true,
        exclude = { ".direnv", "node_modules" },
        layout = { layout = { position = "right" } },
      },
      files = { hidden = true, ignored = true, exclude = { ".direnv", "node_modules" } },
      grep = { hidden = true, exclude = { ".direnv", "node_modules" } },
    },
  },
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
})
