{ pkgs, config, lib, ... }:

let
  colorscheme = {
    plugin = pkgs.custom.neovim-ayu;
    config = ''
      lua vim.g.ayu_mirage = true
      set termguicolors
      colorscheme ayu
    '';
  };

  fzf = {
    plugin = pkgs.vimPlugins.fzf-vim;
    config = ''
      let $FZF_DEFAULT_COMMAND = '${config.programs.fzf.defaultCommand}'
      nnoremap <silent> <C-p> :FZF<CR>
    '';
  };

  easyAlign = {
    plugin = pkgs.vimPlugins.vim-easy-align;
    config = ''
      " Start interactive EasyAlign in visual mode (e.g. vipga)
      xmap <Leader>ga <Plug>(EasyAlign)

      " Start interactive EasyAlign for a motion/text object (e.g. gaip)
      nmap <Leader>ga <Plug>(EasyAlign)
    '';
  };

  ultisnips = {
    plugin = pkgs.vimPlugins.ultisnips;
    config = ''
      let g:UltiSnipsExpandTrigger = '<tab>'
      let g:UltiSnipsJumpForwardTrigger = '<tab>'
      let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
    '';
  };

  treesitter = {
    plugin = pkgs.vimPlugins.nvim-treesitter;
    config = "luafile ${./treesitter.lua}";
  };

  treesitter-parsers = with pkgs.tree-sitter.builtGrammars; [
    { parser = "bash.so";       grammar = tree-sitter-bash; }
    { parser = "c.so";          grammar = tree-sitter-c; }
    { parser = "css.so";        grammar = tree-sitter-css; }
    { parser = "go.so";         grammar = tree-sitter-go; }
    { parser = "javascript.so"; grammar = tree-sitter-javascript; }
    { parser = "json.so";       grammar = tree-sitter-json; }
    { parser = "lua.so";        grammar = tree-sitter-lua; }
    { parser = "markdown.so";   grammar = tree-sitter-markdown; }
    # { parser = "nix.so";        grammar = tree-sitter-nix; }
    { parser = "ruby.so";       grammar = tree-sitter-ruby; }
    { parser = "rust.so";       grammar = tree-sitter-rust; }
    { parser = "scala.so";      grammar = tree-sitter-scala; }
    { parser = "tsx.so";        grammar = tree-sitter-tsx; }
    { parser = "typescript.so"; grammar = tree-sitter-typescript; }
    { parser = "yaml.so";       grammar = tree-sitter-yaml; }
  ];


  nvim-lspconfig = {
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    config = ''
      filetype plugin indent on

      " Avoid showing extra messages when using completion
      set shortmess+=c

      " Always show signcolumn so that it doesnt (dis)appear when a new error happens
      set signcolumn=yes

      luafile ${./lspconfig.lua}

      " Code navigation shortcuts
      nnoremap <silent> gd         <cmd>lua vim.lsp.buf.definition()<CR>
      nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<CR>
      nnoremap <silent> gD         <cmd>lua vim.lsp.buf.implementation()<CR>
      nnoremap <silent> <c-k>      <cmd>lua vim.lsp.buf.signature_help()<CR>
      nnoremap <silent> 0gD        <cmd>lua vim.lsp.buf.type_definition()<CR>
      nnoremap <silent> gr         <cmd>lua vim.lsp.buf.references()<CR>
      nnoremap <silent> g-1        <cmd>lua vim.lsp.buf.document_symbol()<CR>
      nnoremap <silent> gW         <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
      nnoremap <silent> <c-]>      <cmd>lua vim.lsp.buf.declaration()<CR>
      nnoremap <silent> <Leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
      nnoremap <silent> ga         <cmd>lua vim.lsp.buf.code_action()<CR>
      nnoremap <silent> <Leader>fm <cmd>lua vim.lsp.buf.formatting()<CR>

      " Set updatetime for CursorHold
      " 300ms of no cursor movement to trigger CursorHold
      set updatetime=300

      " Show diagnostic popup on cursor hold
      autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

      " Goto previous/next diagnostic warning/error
      nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
      nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

      autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
      \ lua require'lsp_extensions'.inlay_hints{ prefix = "", highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
    '';
  };

  compe = {
    plugin = pkgs.vimPlugins.nvim-compe;
    config = ''
      " Set completeopt to have a better completion experience
      " :help completeopt
      " menuone: popup even when there's only one match
      " noinsert: Do not insert text until a selection is made
      " noselect: Do not select, force user to select one from the menu
      set completeopt=menuone,noinsert,noselect

      lua <<EOF

      require'compe'.setup {
        enabled = true;
        autocomplete = true;
        debug = false;

        source = {
          path = true;
          buffer = true;
          nvim_lsp = true;
          ultisnips = true;
        };
      }

      EOF

      " TODO: set hotkeys to navigate completion
    '';
  };

  telescope = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    config = ''
      nnoremap <silent> <C-f>      <cmd>Telescope live_grep<cr>
      nnoremap <silent> g<tab>     <cmd>Telescope file_browser<cr>
    '';
  };

  galaxyline = {
    plugin = pkgs.vimPlugins.galaxyline-nvim;
    config = ''
      set laststatus=2
      luafile ${./galaxyline.lua}
    '';
  };

  colorizer = {
    plugin = pkgs.vimPlugins.nvim-colorizer-lua;
    config = ''
      lua require'colorizer'.setup()
    '';
  };

  nvim-tree = {
    plugin = pkgs.vimPlugins.nvim-tree-lua;
    config = ''
      source ${./nvim-tree.vim}

      nnoremap <C-n> :NvimTreeToggle<CR>
      nnoremap <leader>r :NvimTreeRefresh<CR>
      nnoremap <leader>n :NvimTreeFindFile<CR>
      " NvimTreeOpen and NvimTreeClose are also available if you need them

      set termguicolors " this variable must be enabled for colors to be applied properly

      " a list of groups can be found at `:help nvim_tree_highlight`
      highlight NvimTreeFolderIcon guibg=blue
    '';
  };

in
{
  # add treesitter grammars
  home.file =
    builtins.listToAttrs (
      builtins.map
        ({ parser, grammar, ... }: {
          name = "${config.xdg.configHome}/nvim/parser/${parser}";
          value = { source = "${grammar}/parser"; };
        })
        treesitter-parsers
    );

  programs.neovim = {
    # use unstable because it has nvim 0.5; make sure to use the *-unwrapped version.
    package = pkgs.unstable.neovim-unwrapped;

    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      rnix-lsp
      nodePackages.typescript-language-server
      rust-analyzer
      gopls
      ripgrep
    ];

    plugins = with pkgs.vimPlugins; [
      # plugins with config (see above)
      colorscheme
      fzf
      easyAlign
      ultisnips
      colorizer
      compe
      nvim-tree

      treesitter
      nvim-treesitter-textobjects # config is inside of treesitter

      nvim-lspconfig
      lsp_extensions-nvim # config inside of nvim-lspconfig

      telescope
      popup-nvim   # config inside of telescope
      plenary-nvim # config inside of telescope

      galaxyline
      nvim-web-devicons # required by galaxyline and nvim-tree

      # other plugins
      vim-nix
      vim-helm
      vim-repeat
      vim-surround
      nerdcommenter
      vim-table-mode
      vim-gitgutter
      editorconfig-vim
    ];

    extraConfig = ''
      " general stuff
      syntax on
      set laststatus=1
      set scrolloff=5
      set clipboard=unnamedplus
      set incsearch
      set nohlsearch
      set mouse=a
      set number relativenumber
      set hidden

      " Toggle search highlight
      nnoremap <C-H> :set hlsearch!<CR>
      
      " Indentation
      set expandtab
      set tabstop=4
      set softtabstop=4
      set shiftwidth=4

      " Use C-j and C-k for scrolling up and down
      imap <C-j> <C-n>
      imap <C-k> <C-p>
    '';
  };
}
