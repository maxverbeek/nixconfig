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
      xmap ga <Plug>(EasyAlign)

      " Start interactive EasyAlign for a motion/text object (e.g. gaip)
      nmap ga <Plug>(EasyAlign)
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

        textobjects = { -- requires nvim-treesitter-textobjects
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

in {
  # add treesitter grammars
  home.file =
    builtins.listToAttrs
      (builtins.map
      ({ parser, grammar, ... }: {
        name = "${config.xdg.configHome}/nvim/parser/${parser}";
        value = { source = "${grammar}/parser"; };
      })
      treesitter-parsers);

  programs.neovim = {
    # use unstable because it has nvim 0.5; make sure to use the *-unwrapped version.
    package = pkgs.unstable.neovim-unwrapped;

    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # plugins with config (see above)
      colorscheme
      fzf
      easyAlign
      ultisnips
      treesitter
      nvim-treesitter-textobjects # config is inside of treesitter

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
