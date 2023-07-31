-- Utilities for creating configurations
local util = require("formatter.util")
local defaults = require("formatter.defaults")

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
  -- Enable or disable logging
  logging = false,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    -- Formatter configurations for filetype "lua" go here
    -- and will be executed in order
    lua = {
      require("formatter.filetypes.lua").stylua,
    },

    typescriptreact = {
      require("formatter.filetypes.typescriptreact").prettierd,
    },

    typescript = {
      require("formatter.filetypes.typescript").prettierd,
    },

    javascriptreact = {
      require("formatter.filetypes.javascriptreact").prettierd,
    },

    javascript = {
      require("formatter.filetypes.javascript").prettierd,
    },

    go = {
      require("formatter.filetypes.go").gofmt,
    },

    rust = {
      require("formatter.filetypes.rust").rustfmt,
    },

    ruby = {
      require("formatter.filetypes.ruby").rubocop,
    },

    c = {
      require("formatter.filetypes.c").clangformat,
    },

    nix = {
      require("formatter.filetypes.nix").nixfmt,
    },

    terraform = {
      require("formatter.filetypes.terraform").terraformfmt,
    },

    yaml = {
      require("formatter.filetypes.yaml").yamlfmt,
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["*"] = function(...)
      if vim.endswith(util.get_current_buffer_file_extension(), "md") then
        -- don't delete two spaces at the end of md files
        return {
          exe = "sed",
          args = {
            vim.fn.shellescape("/\\b  $/!s/[ \\t]*$//g"),
          },
          stdin = true,
        }
      end
      --
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      return require("formatter.filetypes.any").remove_trailing_whitespace(...)
    end,
  },
})

local opt = { noremap = true, silent = false }
vim.api.nvim_set_keymap("n", "<Leader>ff", "<CMD>Format<cr>", opt)

local augroup = vim.api.nvim_create_augroup("FormatOnSave", {})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  command = "FormatWrite",
})

local toggleAutoformat = function()
  if #vim.api.nvim_get_autocmds({ group = augroup }) > 0 then
    vim.api.nvim_clear_autocmds({ group = augroup })
    print("Disabled autoformatting")
  else
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = augroup,
      command = "FormatWrite",
    })
    print("Enabled autoformatting")
  end
end

vim.api.nvim_create_user_command("ToggleFormatting", toggleAutoformat, {})
vim.keymap.set("n", "<F4>", toggleAutoformat)
