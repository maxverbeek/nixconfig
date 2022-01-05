{ pkgs, vimPlugins ? pkgs.vimPlugins, ... }:
with vimPlugins;
let
  addDeps = plugin: deps: plugin.overrideAttrs (old: {
    dependencies = (old.dependencies or []) ++ deps;
  });
in
{
  colorscheme = {
    plugin = pkgs.custom.kanagawa-nvim;
    config = "colorscheme";
  };

  lualine = {
    plugin = lualine-nvim;
    config = "lualine";
  };

  telescope = {
    plugin = addDeps telescope-nvim [
      nvim-web-devicons
      telescope-fzf-native-nvim
    ];
    config = "telescope";
    extern = with pkgs; [ ripgrep ];
  };

  treesitter = {
    plugin = addDeps (nvim-treesitter.withPlugins (_: pkgs.unstable.tree-sitter.allGrammars)) [
      nvim-autopairs
      nvim-treesitter-textobjects
      pkgs.custom.nvim-ts-autotag
      playground
    ];
    config = "treesitter";
  };

  nvim-tree = {
    plugin = nvim-tree-lua;
    config = "nvim-tree";
  };

  nvim-lspconfig = {
    plugin = addDeps nvim-lspconfig [
      lsp_extensions-nvim
      lsp_signature-nvim
    ];
    config = "lsp";
  };

  nvim-cmp = {
    plugin = addDeps nvim-cmp [
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
    ];

    extern = with pkgs; [
      rnix-lsp
      nodePackages.typescript-language-server
      rust-analyzer
      gopls
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
    plugin = comment-nvim;
    config = "comment-nvim";
  };

  harpoon = {
    plugin = harpoon;
    config = "harpoon";
  };

  editorconfig-vim.plugin = editorconfig-vim;
  vim-surround.plugin = vim-surround;
  vim-repeat.plugin = vim-repeat;
  vim-fugitive.plugin = vim-fugitive;
}
