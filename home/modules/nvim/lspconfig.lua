local nvim_lsp = require'lspconfig'

-- Register all the language servers
nvim_lsp.rnix.setup {}
nvim_lsp.tsserver.setup {}
nvim_lsp.rust_analyzer.setup {}
nvim_lsp.gopls.setup {}

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
