require("quarto").setup({
  codeRunner = {
    enabled = true,
    default_method = "molten", -- "molten", "slime", "iron" or <function>
    never_run = { "yaml" }, -- filetypes which are never sent to a code runner
  },
})
