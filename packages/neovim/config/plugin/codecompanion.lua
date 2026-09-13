require("codecompanion").setup({
  adapters = {
    acp = {
      claude_code = function()
        local token = vim.trim(vim.fn.readfile(vim.fn.expand("~/.claude_code_oauth_token"))[1])
        return require("codecompanion.adapters").extend("claude_code", {
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = token,
          },
        })
      end,
    },
  },

  interactions = {
    chat = {
      adapter = "opencode",
    },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>ga", "<cmd>CodeCompanionChat Toggle<cr>")
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>")
