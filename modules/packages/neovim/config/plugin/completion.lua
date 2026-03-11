require("blink.cmp").setup({
  keymap = {
    preset = "none",

    ["<Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        else
          return cmp.select_and_accept()
        end
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },

    ["<C-j>"] = { "select_next", "fallback_to_mappings" },
    ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
  },

  -- should be bundled with the plugin from nixpkgs
  fuzzy = { implementation = "rust" },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  snippets = {
    preset = "luasnip",
  },

  appearance = {
    nerd_font_variant = "mono",
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method("textDocument/documentHighlight") then
      return
    end

    local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. args.buf, { clear = true })

    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      buffer = args.buf,
      callback = function()
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/documentHighlight" })) do
          local params = vim.lsp.util.make_position_params(0, c.offset_encoding)
          c.request("textDocument/documentHighlight", params, nil, args.buf)
        end
      end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end,
})
