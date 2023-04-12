local map = vim.api.nvim_set_keymap

local opts = { noremap = true, silent = true }

require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
			},
		},
	},

	extensions = {
		fzy_native = {
			override_generic_sorter = true,
			override_file_sorter = true,
		},

		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
		},

		file_browser = {
			theme = "ivy",
		},
	},
})

-- require('telescope').load_extension('fzy_native')
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")

local projfiles = function()
	local opts = {} -- define here if you want to define something
	vim.fn.system("git rev-parse --is-inside-work-tree")
	if vim.v.shell_error == 0 then
		require("telescope.builtin").git_files(opts)
	else
		require("telescope.builtin").find_files(opts)
	end
end

vim.keymap.set("n", "<C-p>", projfiles, opts)

map("n", "<C-f>", "<cmd>Telescope live_grep<CR>", opts)
map("n", "<Leader><Tab>", "<cmd>Telescope file_browser<CR>", opts)
map("n", "<Leader>qq", "<cmd>Telescope quickfix<CR>", opts)
