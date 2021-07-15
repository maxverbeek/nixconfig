require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },

  indent = {
    enable = true,
  },

  -- requires nvim-treesitter-textobjects
  textobjects = {
    select = {
      enable = true,

      lookahead = true,

      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",

        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",

        ["iC"] = "@class.inner",
        ["aC"] = "@class.outer",

        ["iB"] = "@block.inner",
        ["aB"] = "@block.outer",

        -- argument (p is already paragraph)
        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",

        -- invocation
        ["ii"] = "@call.inner",
        ["ai"] = "@call.outer",
      },
    },
  },
}

