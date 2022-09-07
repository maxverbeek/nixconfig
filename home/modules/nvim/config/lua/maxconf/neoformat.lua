vim.cmd [[
    augroup fmt
      autocmd!
      autocmd BufWritePre * Neoformat
    augroup END

    let g:neoformat_proto_clangformat = {
    \ 'exe': 'clang-format',
    \ 'args': ['--style=google --assume-filename=file.proto'],
    \ 'no_append': 1,
    \ 'stdin': 1,
    \ }

    let g:neoformat_typescriptreact_standard = {
    \ 'exe': 'ts-standard',
    \ 'stdin': 1,
    \ 'try_node_exe': 1
    \ }

    let g:neoformat_typescript_standard = {
    \ 'exe': 'ts-standard',
    \ 'stdin': 1,
    \ 'try_node_exe': 1
    \ }

    let g:neoformat_enabled_typescript = ['standard', 'prettier']
    let g:neoformat_enabled_typescriptreact = ['standard', 'prettier']
    let g:neoformat_enabled_javascript = ['standard', 'prettier']
    let g:neoformat_enabled_javascriptreact = ['standard', 'prettier']

    let g:neoformat_try_node_exe = 1
    let g:neoformat_enabled_proto = ['clangformat']
]]


local opt = { noremap = true, silent = false }
vim.api.nvim_set_keymap('n', '<Leader>ff', '<CMD>Neoformat<cr>', opt)
vim.api.nvim_set_keymap('x', '<Leader>ff', '<CMD>Neoformat!<cr>', opt)
