{ pkgs, config, lib, ... }:

let
  neovim-ayu = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "neovim-ayu";

    # latest commit as of 2021-07-05
    version = "83f902098e0532d29792b5aa94b5652f85c53bbd";

    src = pkgs.fetchFromGitHub {
      owner = "Shatur";
      repo = "neovim-ayu";
      rev = version;
      sha256 = "sha256-MLOgtQ1SZidKiSOgQkN/fu5umdnWIQs6+92HpMZUuv4=";
    };
  };

  colorscheme = {
    plugin = neovim-ayu;
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
    config = ''
      lua <<EOF
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },

        indent = {
          enable = true,
        },

        -- requires nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,

            lookahead = true,

            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",

              ["ac"] = "@conditional.outer",
              ["ic"] = "@conditional.inner",

              ["iC"] = "@class.inner",
              ["aC"] = "@class.outer",

              ["iB"] = "@block.inner",
              ["aB"] = "@block.outer",

              -- argument (p is already paragraph)
              ["ia"] = "@parameter.inner",
              ["aa"] = "@parameter.outer",

              -- invocation
              ["ii"] = "@call.inner",
              ["ai"] = "@call.outer",
            },
          },
        },
      }
      EOF
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
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    config = ''
      filetype plugin indent on

      " Set completeopt to have a better completion experience
      " :help completeopt
      " menuone: popup even when there's only one match
      " noinsert: Do not insert text until a selection is made
      " noselect: Do not select, force user to select one from the menu
      set completeopt=menuone,noinsert,noselect

      " Avoid showing extra messages when using completion
      set shortmess+=c

      " Always show signcolumn so that it doesnt (dis)appear when a new error happens
      set signcolumn=yes

      lua <<EOF

      local nvim_lsp = require'lspconfig'

      local on_attach = function(client)
        require'completion'.on_attach(client)
      end

      -- Register all the language servers
      nvim_lsp.rnix.setup { on_attach = on_attach }
      nvim_lsp.tsserver.setup { on_attach = on_attach }
      nvim_lsp.rust_analyzer.setup { on_attach = on_attach }

      -- Enable diagnostics
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = true,
          signs = true,
          update_in_insert = true,
        }
      )

      EOF

      " Code navigation shortcuts
      nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
      nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
      nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
      nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
      nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
      nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
      nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
      nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
      nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.declaration()<CR>

      nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>

      " Use <Tab> and <S-Tab> to navigate through popup menu if it's open
      inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      " use <Tab> as trigger keys
      imap <Tab> <Plug>(completion_smart_tab)
      imap <S-Tab> <Plug>(completion_smart_s_tab)

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

in {
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
    ];

    plugins = with pkgs.vimPlugins; [
      # plugins with config (see above)
      colorscheme
      fzf
      easyAlign
      ultisnips

      treesitter
      nvim-treesitter-textobjects # config is inside of treesitter

      nvim-lspconfig
      lsp_extensions-nvim # config inside of nvim-lspconfig
      completion-nvim # config inside of nvim-lspconfig

      # other plugins
      vim-nix
      vim-repeat
      vim-surround
      nerdcommenter
      vim-table-mode
      vim-gitgutter
      lightline-vim
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

      " Toggle search highlight
      nnoremap <C-H> :set hlsearch!<CR>
      
      " Indentation
      set expandtab
      set tabstop=4
      set softtabstop=4
      set shiftwidth=4
    '';
  };
}
