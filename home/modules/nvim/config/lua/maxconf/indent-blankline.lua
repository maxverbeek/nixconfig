require("ibl").setup({
  scope = {
    enabled = true,
    show_start = false,
    char = "▏",
  },

  indent = {
    -- dont show a character for all indentations, only the current scope
    char = " ",
  },
})
