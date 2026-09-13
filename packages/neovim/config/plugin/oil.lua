local never_hidden = {
  [".gitlab-ci.yml"] = true,
  [".researchable"] = true,
}

require("oil").setup({
  skip_confirm_for_simple_edits = true,
  prompt_save_on_select_new_entry = false,
  view_options = {
    is_hidden_file = function(name)
      if never_hidden[name] then
        return false
      end
      return vim.startswith(name, ".")
    end,
  },
})
