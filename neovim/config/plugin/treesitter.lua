-- Treesitter highlighting + indentation
local disabled_ft = {
  cuda = true,
  cpp = true,
  latex = true,
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    if disabled_ft[vim.bo[args.buf].filetype] then
      return
    end

    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)

    if not lang or not pcall(vim.treesitter.language.inspect, lang) then
      return
    end

    vim.treesitter.start(args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Treesitter textobjects
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
})

local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject

local textobject_keymaps = {
  ["af"] = "@function.outer",
  ["if"] = "@function.inner",
  ["ac"] = "@conditional.outer",
  ["ic"] = "@conditional.inner",
  ["iC"] = "@class.inner",
  ["aC"] = "@class.outer",
  ["iB"] = "@block.inner",
  ["aB"] = "@block.outer",
  ["ia"] = "@parameter.inner",
  ["aa"] = "@parameter.outer",
  ["ii"] = "@call.inner",
  ["ai"] = "@call.outer",
}

for key, query in pairs(textobject_keymaps) do
  vim.keymap.set({ "x", "o" }, key, function()
    select_textobject(query, "textobjects")
  end)
end

-- auto set comment string based on ts context
require("ts_context_commentstring").setup({
  enable = true,
  enable_autocmd = false,
})
