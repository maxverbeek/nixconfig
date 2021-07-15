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

      lua <<EOF

      local nvim_lsp = require'lspconfig'

      -- Register all the language servers
      nvim_lsp.rnix.setup {}
      nvim_lsp.tsserver.setup {}
      nvim_lsp.rust_analyzer.setup {}
      nvim_lsp.gopls.setup {}

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

      lua <<EOF

      local gl = require("galaxyline")
      local gls = gl.section

      gl.short_line_list = {" "} -- keeping this table { } as empty will show inactive statuslines

      local ayucolors = require'ayu.colors'

      --  accent = "#FFCC66",
      --  bg = "#1F2430",
      --  black = "#000000",
      --  comment = "#5C6773",
      --  constant = "#D4BFFF",
      --  entity = "#73D0FF",
      --  error = "#FF3333",
      --  fg = "#CBCCC6",
      --  fg_idle = "#607080",
      --  func = "#FFD580",
      --  guide_active = "#576070",
      --  guide_normal = "#383E4C",
      --  gutter_active = "#5F687A",
      --  gutter_normal = "#404755",
      --  keyword = "#FFA759",
      --  line = "#191E2A",
      --  markup = "#F28779",
      --  operator = "#F29E74",
      --  panel_bg = "#232834",
      --  panel_border = "#101521",
      --  panel_shadow = "#141925",
      --  regexp = "#95E6CB",
      --  selection_bg = "#33415E",
      --  selection_border = "#232A4C",
      --  selection_inactive = "#323A4C",
      --  special = "#FFE6B3",
      --  string = "#BAE67E",
      --  tag = "#5CCFE6",
      --  ui = "#707A8C",
      --  vcs_added = "#A6CC70",
      --  vcs_added_bg = "#313D37",
      --  vcs_diff_text = "#465742",
      --  vcs_modified = "#77A8D9",
      --  vcs_modified_bg = "#323A4C",
      --  vcs_removed = "#F27983",
      --  vcs_removed_bg = "#3E373A",
      --  warning = "#FFA759",
      --  white = "#FFFFFF"

      -- local colors = {
      --   bg = "#2e303e",
      --   line_bg = "#2e303e",
      --   fg = "#e3e6ee",
      --   green = "#29d398",
      --   orange = "#efb993",
      --   red = "#e95678",
      --   lightbg = "#2e303e",
      --   lightbasdfg = "#393b4d",
      --   nord = "#9699b7",
      --   greenYel = "#efb993"
      -- }

      local colors = {
          bg = ayucolors.bg,
          line_bg = ayucolors.bg,
          fg = ayucolors.fg,
          green = ayucolors.string,
          orange = ayucolors.warning,
          red = ayucolors.vcs_removed,
          yellow = ayucolors.accent,
          lightbg = ayucolors.bg,
          nord = ayucolors.constant,
          greenYel = ayucolors.vcs_added,
      }

      gls.left[1] = {
          leftRounded = {
              provider = function()
                  return " "
              end,
              highlight = {colors.nord, colors.bg}
          }
      }

      gls.left[2] = {
          statusIcon = {
              provider = function()
                  return "  "
              end,
              highlight = {colors.fg, colors.bg},
              separator = " ",
              separator_highlight = {colors.lightbg, colors.lightbg}
          }
      }

      gls.left[3] = {
          FileIcon = {
              provider = "FileIcon",
              condition = buffer_not_empty,
              highlight = {require("galaxyline.provider_fileinfo").get_file_icon_color, colors.lightbg}
          }
      }

      gls.left[4] = {
          FileName = {
              provider = {"FileName", "FileSize"},
              condition = buffer_not_empty,
              highlight = {colors.fg, colors.lightbg},
              separator = " ",
              separator_highlight = {colors.line_bg, colors.line_bg}
          }
      }

      gls.left[5] = {
          teech = {
              provider = function()
                  return " "
              end,
              separator = " ",
              highlight = {colors.lightbg, colors.bg}
          }
      }

      local checkwidth = function()
          local squeeze_width = vim.fn.winwidth(0) / 2
          if squeeze_width > 40 then
              return true
          end
          return false
      end

      gls.left[6] = {
          DiffAdd = {
              provider = "DiffAdd",
              condition = checkwidth,
              icon = "   ",
              highlight = {colors.greenYel, colors.line_bg}
          }
      }

      gls.left[7] = {
          DiffModified = {
              provider = "DiffModified",
              condition = checkwidth,
              icon = " ",
              highlight = {colors.orange, colors.line_bg}
          }
      }

      gls.left[8] = {
          DiffRemove = {
              provider = "DiffRemove",
              condition = checkwidth,
              icon = " ",
              highlight = {colors.red, colors.line_bg}
          }
      }

      gls.left[9] = {
          LeftEnd = {
              provider = function()
                  return " "
              end,
              separator = " ",
              separator_highlight = {colors.line_bg, colors.line_bg},
              highlight = {colors.line_bg, colors.line_bg}
          }
      }

      gls.left[10] = {
          DiagnosticError = {
              provider = "DiagnosticError",
              icon = "  ",
              highlight = {colors.orange, colors.bg}
          }
      }

      gls.left[11] = {
          Space = {
              provider = function()
                  return " "
              end,
              highlight = {colors.line_bg, colors.line_bg}
          }
      }

      gls.left[12] = {
          DiagnosticWarn = {
              provider = "DiagnosticWarn",
              icon = "  ",
              highlight = {colors.yellow, colors.bg}
          }
      }

      gls.right[1] = {
          GitIcon = {
              provider = function()
                  return "   "
              end,
              condition = require("galaxyline.provider_vcs").check_git_workspace,
              highlight = {colors.green, colors.line_bg}
          }
      }

      gls.right[2] = {
          GitBranch = {
              provider = "GitBranch",
              condition = require("galaxyline.provider_vcs").check_git_workspace,
              highlight = {colors.green, colors.line_bg}
          }
      }

      gls.right[3] = {
          right_LeftRounded = {
              provider = function()
                  return " " 
              end,
              separator = " ",
              separator_highlight = {colors.bg, colors.bg},
              highlight = {colors.lightbg, colors.bg}
          }
      }

      gls.right[4] = {
          ViMode = {
              provider = function()
                  local alias = {
                      n = "NORMAL",
                      i = "INSERT",
                      c = "COMMAND",
                      V = "VISUAL",
                      [""] = "VISUAL",
                      v = "VISUAL",
                      R = "REPLACE"
                  }
                  return alias[vim.fn.mode()]
              end,
              highlight = {colors.fg, colors.lightbg}
          }
      }

      gls.right[5] = {
          PerCent = {
              provider = "LinePercent",
              separator = " ",
              separator_highlight = {colors.lightbg, colors.lightbg},
              highlight = {colors.fg, colors.lightbg}
          }
      }

      gls.right[6] = {
          rightRounded = {
              provider = function()
                  return " "
              end,
              highlight = {colors.lightbg, colors.bg}
          }
      }
      EOF
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
      let g:nvim_tree_side = 'left' "left by default
      let g:nvim_tree_width = 30 "30 by default, can be width_in_columns or 'width_in_percent%'
      let g:nvim_tree_ignore = [ '.git', 'node_modules', '.cache' ] "empty by default
      let g:nvim_tree_gitignore = 1 "0 by default
      let g:nvim_tree_auto_open = 1 "0 by default, opens the tree when typing `vim $DIR` or `vim`
      let g:nvim_tree_auto_close = 1 "0 by default, closes the tree when it's the last window
      let g:nvim_tree_auto_ignore_ft = [] "empty by default, don't auto open tree on specific filetypes.
      let g:nvim_tree_quit_on_open = 1 "0 by default, closes the tree when you open a file
      let g:nvim_tree_follow = 1 "0 by default, this option allows the cursor to be updated when entering a buffer
      let g:nvim_tree_indent_markers = 0 "0 by default, this option shows indent markers when folders are open
      let g:nvim_tree_hide_dotfiles = 0 "0 by default, this option hides files and folders starting with a dot `.`
      let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
      let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
      let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
      let g:nvim_tree_tab_open = 1 "0 by default, will open the tree when entering a new tab and the tree was previously open
      let g:nvim_tree_auto_resize = 0 "1 by default, will resize the tree to its saved width when opening a file
      let g:nvim_tree_disable_netrw = 1 "1 by default, disables netrw
      let g:nvim_tree_hijack_netrw = 0 "1 by default, prevents netrw from automatically opening when opening directories (but lets you keep its other utilities)
      let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
      let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
      let g:nvim_tree_lsp_diagnostics = 1 "0 by default, will show lsp diagnostics in the signcolumn. See :help nvim_tree_lsp_diagnostics
      let g:nvim_tree_disable_window_picker = 1 "0 by default, will disable the window picker.
      let g:nvim_tree_hijack_cursor = 0 "1 by default, when moving cursor in the tree, will position the cursor at the start of the file on the current line
      let g:nvim_tree_icon_padding = ' ' "one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
      let g:nvim_tree_update_cwd = 1 "0 by default, will update the tree cwd when changing nvim's directory (DirChanged event). Behaves strangely with autochdir set.
      let g:nvim_tree_window_picker_exclude = {
      \   'filetype': [
      \     'packer',
      \     'qf'
      \   ],
      \   'buftype': [
      \     'terminal'
      \   ]
      \ }
      " Dictionary of buffer option names mapped to a list of option values that
      " indicates to the window picker that the buffer's window should not be
      " selectable.
      let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1 } " List of filenames that gets highlighted with NvimTreeSpecialFile
      let g:nvim_tree_show_icons = {
      \ 'git': 1,
      \ 'folders': 1,
      \ 'files': 1,
      \ 'folder_arrows': 1,
      \ }
      "If 0, do not show the icons for one of 'git' 'folder' and 'files'
      "1 by default, notice that if 'files' is 1, it will only display
      "if nvim-web-devicons is installed and on your runtimepath.
      "if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
      "but this will not work when you set indent_markers (because of UI conflict)

      " default will show icon by default if no icon is provided
      " default shows no icon by default
      let g:nvim_tree_icons = {
      \ 'default': '',
      \ 'symlink': '',
      \ 'git': {
      \   'unstaged': "✗",
      \   'staged': "✓",
      \   'unmerged': "",
      \   'renamed': "➜",
      \   'untracked': "★",
      \   'deleted': "",
      \   'ignored': "◌"
      \   },
      \ 'folder': {
      \   'arrow_open': "",
      \   'arrow_closed': "",
      \   'default': "",
      \   'open': "",
      \   'empty': "",
      \   'empty_open': "",
      \   'symlink': "",
      \   'symlink_open': "",
      \   },
      \   'lsp': {
      \     'hint': "",
      \     'info': "",
      \     'warning': "",
      \     'error': "",
      \   }
      \ }

      nnoremap <C-n> :NvimTreeToggle<CR>
      nnoremap <leader>r :NvimTreeRefresh<CR>
      nnoremap <leader>n :NvimTreeFindFile<CR>
      " NvimTreeOpen and NvimTreeClose are also available if you need them

      set termguicolors " this variable must be enabled for colors to be applied properly

      " a list of groups can be found at `:help nvim_tree_highlight`
      highlight NvimTreeFolderIcon guibg=blue
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

      treesitter
      nvim-treesitter-textobjects # config is inside of treesitter

      nvim-lspconfig
      lsp_extensions-nvim # config inside of nvim-lspconfig

      compe

      nvim-tree

      telescope
      popup-nvim   # config inside of telescope
      plenary-nvim # config inside of telescope

      galaxyline
      nvim-web-devicons # required by galaxyline

      # other plugins
      vim-nix
      vim-helm
      vim-repeat
      vim-surround
      nerdcommenter
      vim-table-mode
      vim-gitgutter
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
    '';
  };
}
