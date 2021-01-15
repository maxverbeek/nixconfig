" Load plugin loader
let plug_install = 0
let autoload_plug_path = stdpath('config') . '/autoload/plug.vim'
if !filereadable(autoload_plug_path)
    silent exe '!curl -fL --create-dirs -o ' . autoload_plug_path . 
        \ ' https://raw.github.com/junegunn/vim-plug/master/plug.vim'
    execute 'source ' . fnameescape(autoload_plug_path)
    let plug_install = 1
endif
unlet autoload_plug_path

" Plugins!
call plug#begin('~/.config/nvim/plugins')
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug '/usr/bin/fzf'
Plug 'airblade/vim-gitgutter'
Plug 'conornewton/vim-pandoc-markdown-preview'
Plug 'dhruvasagar/vim-table-mode'
Plug 'hashivim/vim-terraform'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'joshdick/onedark.vim'
Plug 'junegunn/vim-easy-align'
Plug 'lervag/vimtex'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdcommenter' 
Plug 'sirver/ultisnips'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
call plug#end()

if plug_install
    PlugInstall --sync
endif
unlet plug_install

syntax on 
colorscheme onedark
set termguicolors
"set noshowmode " done by lightline.vim
set laststatus=1
set scrolloff=5
set clipboard=unnamedplus
set incsearch
set nohlsearch

" Toggle search highlight
nnoremap <C-H> :set hlsearch!<CR>

" Indentation
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set mouse=a

" 1 split terminal is 86 characters on my screen
set textwidth=86

" Line nums
set number relativenumber

" FZF file finder
let $FZF_DEFAULT_COMMAND = "find -L -not -path '*/\.git/*'"
nnoremap <silent> <C-p> :FZF<CR>

" Vimtex
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'
let g:vimtex_compiler_progname='nvr'

augroup latexSurround
 autocmd!
 autocmd FileType tex call s:latexSurround()
augroup END

function! s:latexSurround()
 let b:surround_{char2nr("e")} = "\\begin{\1environment: \1}\n\t\r\n\\end{\1\1}"
 let b:surround_{char2nr("c")} = "\\\1command: \1{\r}"
endfunction

" vim-pandoc
let g:md_pdf_viewer="zathura"

" easy align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


"coc
"inoremap <silent><expr> <TAB>
      "\ pumvisible() ? coc#_select_confirm() :
      "\ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      "\ <SID>check_back_space() ? "\<TAB>" :
      "\ coc#refresh()

"function! s:check_back_space() abort
  "let col = col('.') - 1
  "return !col || getline('.')[col - 1]  =~# '\s'
"endfunction

"let g:coc_snippet_next = '<tab>'

" UltiSnips
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" Fix compatability with virtual env
let g:python3_host_prog = '/usr/bin/python3'

" Syntax highlighting in Markdown

autocmd BufNewFile,BufRead *.md set filetype=markdown

let g:markdown_fenced_languages = ['bash=sh', 'go', 'css', 'django', 'javascript', 'js=javascript', 'json=javascript', 'perl', 'php', 'python', 'ruby', 'sass', 'xml', 'html']

command! -range FormatShellCmd <line1>!format_shell_cmd.py
