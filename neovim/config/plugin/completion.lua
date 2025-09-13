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
    preset = "luasnip"
  },

  appearance = {
    nerd_font_variant = "mono",
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method("textDocument/documentHighlight") then
      vim.cmd([[
        augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]])
    end
  end,
})
