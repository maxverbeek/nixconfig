local snacks = require("snacks")

snacks.setup({
  picker = {
    enabled = true,
    sources = {
      explorer = {
        auto_close = true,
        hidden = true,
        args = { "--no-ignore-global" },
        exclude = { ".direnv", "node_modules" },
        layout = { layout = { position = "right" } },
      },
      files = { hidden = true, args = { "--no-ignore-global" }, exclude = { ".direnv", "node_modules" } },
      grep = { hidden = true, exclude = { ".direnv", "node_modules" } },
    },
  },
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
})
