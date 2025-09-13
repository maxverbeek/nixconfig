local ls = require('luasnip')

ls.setup({

  -- Allow to move between snippet expansions after leaving snippet
  history = true,

  -- Update snip contents in insertmode
  updateevents = "TextChanged,TextChangedI",
})

-- <C-h> and <C-l> to move back and forwards within a snippet
vim.keymap.set({ "i", "s", "n" }, "<c-h>", function()
  if ls.locally_jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set({ "i", "s", "n" }, "<c-l>", function()
  if ls.locally_jumpable(1) then
    ls.jump(1)
  end
end, { silent = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if ls.session.current_nodes[vim.api.nvim_get_current_buf()] and not ls.session.jump_active then
      ls.unlink_current()
    end
  end,
})

require("luasnip.loaders.from_lua").load()
