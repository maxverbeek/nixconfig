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
	fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    
    file_browser = {
        theme = "ivy",
    },
  },
}

require('telescope').load_extension('fzy_native')
require('telescope').load_extension('file_browser')

map('n', '<C-p>', '<cmd>Telescope find_files --hidden=true<CR>', opts)
map('n', '<C-f>', '<cmd>Telescope live_grep<CR>', opts)
map('n', '<Leader><Tab>', '<cmd>Telescope file_browser<CR>', opts)
