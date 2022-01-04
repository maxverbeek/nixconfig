local map = vim.api.nvim_set_keymap

local opts = { noremap = true, silent = true }

require 'telescope'.setup {
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous"
      }
    }
  },

  extensions = {
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case", -- ignore_case, respect_case, smart_case
    },
  },
}

require('telescope').load_extension('fzf')

map('n', '<C-p>', '<cmd>Telescope find_files<CR>', opts)
map('n', '<C-f>', '<cmd>Telescope live_grep<CR>', opts)
