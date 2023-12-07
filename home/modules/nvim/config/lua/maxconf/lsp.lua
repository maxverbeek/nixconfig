vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.signcolumn = "yes"

-- Set update time for cursorhold autocommand
vim.o.updatetime = 300

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = { border = "single" },
})

vim.cmd([[
  augroup holddiagnostics
    autocmd!
    autocmd CursorHold * lua vim.diagnostic.open_float({ scope = "cursor", focusable = false })
  augroup END
]])

vim.cmd([[
  autocmd BufEnter,BufWritePost <buffer> :lua require('lsp_extensions.inlay_hints').request {aligned = true, prefix = " » "}
]])

vim.opt.completeopt:append({ "menu", "menuone", "noselect" })

-- View references in telescope instead of quickfixlist
local has_telescope, telescope_builtin = pcall(require, "telescope.builtin")

if has_telescope then
  vim.lsp.handlers["textDocument/references"] = telescope_builtin.lsp_references
  vim.lsp.handlers["textDocument/implementation"] = telescope_builtin.lsp_implementations
end

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      -- For `luasnip` user.
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),

    -- ["<Tab>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    -- Move back and forwards in cmp if there are suggestions, otherwise move
    -- back and forwards within luasnip if there is a snippet
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-k>"] = cmp.mapping.select_prev_item(),

    -- ["<C-j>"] = cmp.mapping(function(fallback)
    -- 	if cmp.visible() then
    -- 		cmp.select_next_item()
    -- 	elseif luasnip.locally_jumpable(1) then
    -- 		luasnip.jump(1)
    -- 	else
    -- 		fallback()
    -- 	end
    -- end, { "i", "s" }),
    --
    -- ["<C-k>"] = cmp.mapping(function(fallback)
    -- 	if cmp.visible() then
    -- 		cmp.select_prev_item()
    -- 	elseif luasnip.locally_jumpable(-1) then
    -- 		luasnip.jump(-1)
    -- 	else
    -- 		fallback()
    -- 	end
    -- end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },

  formatting = {
    format = require("lspkind").cmp_format({
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        path = "[path]",
        luasnip = "[snip]",
      },
    }),
  },
})

require("lsp_signature").setup({
  bind = true,
  floating_window_above_cur_line = true,
})

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  local opts = { noremap = true, silent = true }

  local function map(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  map("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  map("n", "gk", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  map("n", "0gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  map("n", "g-1", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
  map("n", "gW", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
  map("n", "<c-]>", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  map("n", "<Leader>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  map("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  map("n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

  -- Goto previous/next diagnostic warning/error
  map("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  map("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

  -- highlight word under cursor
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]])
  end
end

-- Setup lspconfig.
local nvim_lsp = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Register all the language servers
local servers =
  { "nil_ls", "rust_analyzer", "gopls", "tailwindcss", "svelte", "pyright", "clangd", "texlab", "terraformls", "metals" }

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Register tsserver separately

nvim_lsp["tsserver"].setup({
  on_attach = on_attach,
  capabilities = capabilities,
  handlers = {
    ["textDocument/definition"] = function(err, result, ctx, config)
      -- dont show results from node_modules when there are results that aren't from node_modules.
      local projectres = vim.tbl_filter(function(v)
        return not string.find(v.targetUri, "node_modules")
      end, result)

      if #projectres > 0 then
        result = projectres
      end

      -- call the actual handler with the (modified) result
      vim.lsp.handlers["textDocument/definition"](err, result, ctx, config)
    end,
  },
})
