{ pkgs, config, lib, ... }:

let
  colorscheme = {
    # plugin = pkgs.custom.neovim-ayu;
    plugin = pkgs.vimPlugins.gruvbox-community;
    # config = ''
    #   lua vim.g.ayu_mirage = true
    #   set termguicolors
    #   colorscheme ayu
    # '';
    config = ''
      set termguicolors
      colorscheme gruvbox
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
    plugin = with pkgs.vimPlugins; [
      nvim-treesitter
      playground # no config, but this is treesitter-playground
      nvim-treesitter-textobjects # config is inside of treesitter
    ];
    config = "luafile ${./treesitter.lua}";
  };

  vim-go = {
    plugin = pkgs.vimPlugins.vim-go;
    config = ''
      let g:go_fmt_command = "goimports"
      let g:go_fmt_autosave = 1
    '';
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
    { parser = "nix.so";        grammar = tree-sitter-nix; }
    { parser = "ruby.so";       grammar = tree-sitter-ruby; }
    { parser = "rust.so";       grammar = tree-sitter-rust; }
    { parser = "scala.so";      grammar = tree-sitter-scala; }
    { parser = "tsx.so";        grammar = tree-sitter-tsx; }
    { parser = "typescript.so"; grammar = tree-sitter-typescript; }
    { parser = "yaml.so";       grammar = tree-sitter-yaml; }
  ];

  nvim-lspconfig = {
    plugin = with pkgs.vimPlugins; [
      pkgs.vimPlugins.nvim-lspconfig
      lsp_extensions-nvim # config inside of nvim-lspconfig
    ];

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

  cmp = {
    plugin = [
      pkgs.custom.nvim-cmp
      pkgs.custom.cmp-nvim-lsp
      pkgs.custom.cmp-path
      pkgs.custom.cmp-buffer
    ];

    config = ''
      set completeopt=menu,menuone,noselect

      lua <<EOF
        -- Setup nvim-cmp.
        local cmp = require'cmp'

        cmp.setup({
          snippet = {
            expand = function(args)
              -- For `vsnip` user.
              -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.

              -- For `luasnip` user.
              -- require('luasnip').lsp_expand(args.body)

              -- For `ultisnips` user.
              vim.fn["UltiSnips#Anon"](args.body)
            end,
          },
          mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<Tab>'] = cmp.mapping.confirm({ select = true }),
          },
          sources = {
            { name = 'nvim_lsp' },
            -- { name = 'ultisnips' },
            { name = 'buffer' },
            { name = 'path' },
          }
        })

        local on_attach = function(_, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end

        -- Setup lspconfig.
        local nvim_lsp = require'lspconfig'
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

        -- Register all the language servers
        local servers = { 'rnix', 'tsserver', 'rust_analyzer', 'gopls' }

        for _, lsp in ipairs(servers) do
          nvim_lsp[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
          }
        end
      EOF
    '';
  };

  telescope = {
    plugin = with pkgs.vimPlugins; [
      telescope-nvim
      popup-nvim   # config inside of telescope
      plenary-nvim # config inside of telescope
    ];

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

  lualine = {
    plugin = with pkgs.vimPlugins; [
      lualine-nvim
      nvim-web-devicons # required by galaxyline and nvim-tree
    ];

    config = ''
      set laststatus=2
      luafile ${./lualine.lua}
    '';
  };

  colorizer = {
    plugin = pkgs.vimPlugins.nvim-colorizer-lua;
    config = ''
      lua require'colorizer'.setup()
    '';
  };

  nvim-tree = {
    plugin = with pkgs.vimPlugins; [
      nvim-tree-lua
      nvim-web-devicons # required by galaxyline and nvim-tree
    ];

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

  vimtex = {
    plugin = pkgs.vimPlugins.vimtex;
    config = ''
      let g:tex_flavor='latex'
      let g:vimtex_view_method='zathura'
      let g:vimtex_quickfix_mode=0
      let g:vimtex_compiler_progname='nvr'
    '';
  };

  pandoc-preview = {
    plugin = pkgs.custom.vim-pandoc-markdown-preview;
    config = ''
      let g:md_pdf_viewer='zathura'
    '';
  };


  ############

  mkNormalisedPlugins = (plugins: map (plug: plug // { plugin = lib.toList plug.plugin; }) plugins);

  mkPluginConfig = (name: plugin: 
    if plugin ? config then ''
      " ${name} {{{
      ${plugin.config}
      " }}}
    '' else ""
  );

  mkNormalisedConfig = plugs: (builtins.concatStringsSep "\n" (builtins.catAttrs "config" plugs));

  nvim = pkgs.unstable.neovim.override {
    configure = {
      plug.plugins = lib.unique (
        unconfiguredPlugins ++
        builtins.concatLists (builtins.catAttrs "plugin" (mkNormalisedPlugins configuredPlugs))
      );
      customRC = ''
        ${extraConfig}
        " Start plugins
        ${(mkNormalisedConfig configuredPlugs)}
      '';
    };
  };

  configuredPlugs = [
    colorscheme
    fzf
    easyAlign
    ultisnips
    colorizer
    nvim-tree
    vim-go
    vimtex
    pandoc-preview
    cmp
    treesitter
    nvim-lspconfig
    telescope
    lualine
  ];

  unconfiguredPlugins = with pkgs.vimPlugins; [
    pkgs.custom.nvim-ts-autotag # doesn't exist yet in nixpkgs

    # other plugins
    vim-nix
    vim-helm
    vim-repeat
    vim-surround
    nerdcommenter
    vim-table-mode
    vim-gitgutter
    editorconfig-vim
    vim-endwise
    auto-pairs
    vim-markdown
    vim-fugitive
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

    let mapleader=" "

    " Toggle search highlight
    nnoremap <C-H> :set hlsearch!<CR>
    
    " Indentation
    set expandtab
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set smarttab

    " Use C-j and C-k for scrolling up and down
    imap <C-j> <C-n>
    imap <C-k> <C-p>

    " Quickfix list
    nnoremap <Leader>cq :cclose<CR>
    nnoremap <Leader>cj :cnext<CR>
    nnoremap <Leader>ck :cprev<CR>
  '';

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
    package = nvim;

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

  };
}
