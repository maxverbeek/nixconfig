{ pkgs, vimPlugins ? pkgs.vimPlugins, ... }:
with vimPlugins;
let
  addDeps = plugin: deps:
    plugin.overrideAttrs
    (old: { dependencies = (old.dependencies or [ ]) ++ deps; });
in {
  colorscheme = {
    plugin = pkgs.custom.kanagawa-nvim;
    config = "colorscheme";
  };

  colorschemelight = {
    plugin = gruvbox-community;
    config = "presentations";
  };

  lualine = {
    plugin = lualine-nvim;
    config = "lualine";
  };

  telescope = {
    plugin = addDeps telescope-nvim [
      nvim-web-devicons
      telescope-fzy-native-nvim
      telescope-file-browser-nvim
    ];
    config = "telescope";
    extern = with pkgs; [ ripgrep fd ];
  };

  treesitter = {
    plugin = addDeps nvim-treesitter.withAllGrammars [
        nvim-autopairs
        nvim-treesitter-textobjects
        nvim-ts-autotag
        playground
      ];
    config = "treesitter";
  };

  nvim-tree = {
    plugin = nvim-tree-lua;
    config = "nvim-tree";
  };

  nvim-lspconfig = {
    plugin = addDeps nvim-lspconfig [ lsp_extensions-nvim lsp_signature-nvim ];
    config = "lsp";
  };

  nvim-cmp = {
    plugin = addDeps nvim-cmp [ cmp-nvim-lsp cmp-buffer cmp-path ];

    extern = with pkgs; [
      rnix-lsp
      nodePackages.typescript-language-server
      unstable.nodePackages."@tailwindcss/language-server"
      unstable.nodePackages."svelte-language-server"
      rust-analyzer
      gopls
      pyright
      clang-tools
    ];

    # config is in lsp
  };

  vim-easy-align = {
    plugin = vim-easy-align;
    config = "easy-align";
  };

  gitsigns-nvim = {
    plugin = gitsigns-nvim;
    config = "gitsigns";
  };

  nvim-autopairs = {
    plugin = nvim-autopairs;
    config = "nvim-autopairs";
  };

  nvim-colorizer = {
    plugin = nvim-colorizer-lua;
    config = "nvim-colorizer";
  };

  comment-nvim = {
    plugin = addDeps comment-nvim [ nvim-ts-context-commentstring ];
    config = "comment-nvim";
  };

  harpoon = {
    plugin = harpoon;
    config = "harpoon";
  };

  indent-blankline-nvim = {
    plugin = indent-blankline-nvim;
    config = "indent-blankline";
  };

  neoformat = {
    plugin = neoformat;
    config = "neoformat";
    extern = with pkgs; [
      nixfmt
      custom.rubocop
      unstable.nodePackages.prettier
      unstable.nodePackages.vscode-langservers-extracted
    ];
  };

  luasnip.plugin = luasnip;

  dressing-nvim = {
    plugin = dressing-nvim;
    config = "dressing";
  };

  editorconfig-vim.plugin = editorconfig-vim;
  vim-surround.plugin = vim-surround;
  vim-repeat.plugin = vim-repeat;
  vim-fugitive.plugin = vim-fugitive;
}
