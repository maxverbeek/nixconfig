function string:contains(sub)
  return self:find(sub, 1, true) ~= nil
end

local format_js = function(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)

  -- nasty check to see if working on base-platform because we use custom rules there
  if path:contains("sdv") ~= nil and path:contains("base-platform") ~= nil then
    return { "standardjs" }
  end

  return { { "prettierd", "prettier", "standardjs" } }
end

local format_ts = function(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)

  -- nasty check to see if working on base-platform because we use custom rules there
  if path:contains("sdv") ~= nil and path:contains("base-platform") ~= nil then
    return { "standardts" }
  end

  return { { "prettierd", "prettier", "standardts" } }
end

local util = require("conform.util")

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("conform").setup({
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
  -- Conform will notify you when no formatters are available for the buffer
  notify_no_formatters = true,
  formatters = {
    standardts = {
      command = util.from_node_modules("ts-standard"),
      args = { "--fix", "--stdin", "--stdin-filename", "$FILENAME" },
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },

    -- Use a sub-list to run only the first available formatter
    javascript = format_js,
    javascriptreact = format_js,
    typescript = format_ts,
    typescriptreact = format_ts,

    json = { "jq" },
    go = { "gofmt" },
    rust = { "rustfmt" },
    ruby = { "rubocop" },
    c = { "clangformat" },
    nix = { "nixfmt" },
    terraform = { "terraform_fmt" },
  },
})
-- -- Use the special "*" filetype for defining formatter configurations on
-- -- any filetype
-- ["*"] = function(...)
--   if vim.endswith(util.get_current_buffer_file_extension(), "md") then
--     -- don't delete two spaces at the end of md files
--     return {
--       exe = "sed",
--       args = {
--         vim.fn.shellescape("/\\S  $/!s/[ \\t]*$//;s/^  $//"),
--       },
--       stdin = true,
--     }
--   end
--   --
--   -- "formatter.filetypes.any" defines default configurations for any
--   -- filetype
--   return require("formatter.filetypes.any").remove_trailing_whitespace(...)
-- end,

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

local opt = { noremap = true, silent = false }
vim.api.nvim_set_keymap("n", "<Leader>ff", "<CMD>Format<cr>", opt)

require("conform").setup({
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

vim.keymap.set("n", "<F6>", function()
  if vim.g.disable_autoformat then
    vim.g.disable_autoformat = false
    print("Enabled autoformat")
  else
    vim.g.disable_autoformat = true
    print("Disabled autoformat")
  end
end)
