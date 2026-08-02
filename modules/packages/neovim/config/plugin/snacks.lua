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

-- LSP $/progress (e.g. ruby-lsp "indexing files") in a dedicated bottom-right
-- float. Kept separate from the snacks notifier so normal vim.notify messages
-- still go to the statusbar, not popups.
local lsp_progress = {} -- client_id -> { win, timer }

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local val = ev.data and ev.data.params and ev.data.params.value
    if not val then
      return
    end
    local id = ev.data.client_id
    local client = vim.lsp.get_client_by_id(id)
    local name = client and client.name or "lsp"
    local msg = val.message and (val.title .. ": " .. val.message) or val.title
    if val.percentage then
      msg = string.format("%s (%d%%)", msg, val.percentage)
    end
    local text = " " .. name .. " — " .. msg .. " "

    local state = lsp_progress[id]
    if not state or not (state.win and state.win:valid()) then
      state = {
        win = snacks.win({
          relative = "editor",
          row = -1, -- bottom
          col = -1, -- right
          width = #text,
          height = 1,
          focusable = false,
          enter = false,
          border = "rounded",
          backdrop = false,
          wo = { winhighlight = "Normal:SnacksNotifierInfo" },
        }),
      }
      lsp_progress[id] = state
    end

    if state.timer then
      state.timer:stop()
    end
    local buf = state.win.buf
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    state.win:update({ width = #text })

    if val.kind == "end" then
      state.timer = vim.defer_fn(function()
        if state.win and state.win:valid() then
          state.win:close()
        end
        lsp_progress[id] = nil
      end, 1500)
    end
  end,
})
