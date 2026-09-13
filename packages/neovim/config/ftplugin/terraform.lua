vim.keymap.set("n", "<leader>ty", function()
  local addr = require("terraform-yank").get_address()
  if addr then
    vim.fn.setreg("+", addr)
    vim.notify(addr, vim.log.levels.INFO)
  else
    vim.notify("No terraform block found", vim.log.levels.WARN)
  end
end, { buffer = true })
