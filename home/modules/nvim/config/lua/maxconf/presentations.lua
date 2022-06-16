vim.api.nvim_create_user_command("Light", function ()
    vim.o.bg = 'light'
    vim.cmd("colorscheme gruvbox")
end, {})
