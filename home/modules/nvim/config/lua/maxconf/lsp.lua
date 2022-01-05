vim.o.shortmess = vim.o.shortmess .. 'c'
vim.o.signcolumn = 'yes'

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
map('n', 'gD', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
map('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
map('n', '0gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
map('n', 'g-1', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
map('n', 'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
map('n', '<c-]>', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
map('n', '<Leader>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
map('n', 'ga',         "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
map('n', 'K',          "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
map('n', '<Leader>rn', "<cmd>lua vim.lsp.buf.rename()<CR>", opts)


-- Set update time for cursorhold autocommand
vim.o.updatetime = 300

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    float = { border = "single" },
})

-- Goto previous/next diagnostic warning/error
map('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
map('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

vim.cmd([[
  augroup holddiagnostics
    autocmd!
    autocmd CursorHold * lua vim.diagnostic.open_float({ scope = "cursor" })
  augroup END
]])

vim.cmd [[
  autocmd BufEnter,BufWritePost <buffer> :lua require('lsp_extensions.inlay_hints').request {aligned = true, prefix = " » "}
]]

vim.opt.completeopt:append({ 'menu', 'menuone', 'noselect' })

-- View references in telescope instead of quickfixlist
local has_telescope, telescope_builtin = pcall(require, "telescope.builtin")

if has_telescope then
  vim.lsp.handlers["textDocument/references"] = telescope_builtin.lsp_references
  vim.lsp.handlers["textDocument/implementation"] = telescope_builtin.lsp_implementations
end

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      -- For `vsnip` user.
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.
      -- For `luasnip` user.
      -- require('luasnip').lsp_expand(args.body)
      -- For `ultisnips` user.
      -- vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
  },
  sources = {
    { name = 'nvim_lsp' },
    -- { name = 'ultisnips' },
    { name = 'buffer' },
    { name = 'path' },
  }
})

require 'lsp_signature'.setup {
  bind = true,
  floating_window_above_cur_line = false,
}

local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end
-- Setup lspconfig.
local nvim_lsp = require'lspconfig'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
-- Register all the language servers
local servers = { 'rnix', 'tsserver', 'rust_analyzer', 'gopls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
