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
    config = ./config/lua/colorscheme.lua;
  };

  lualine = {
    plugin = lualine-nvim;
    config = ./config/lua/lualine.lua;
  };

  telescope = {
    plugin = addDeps telescope-nvim [
      nvim-web-devicons
      telescope-fzf-native-nvim
    ];
    config = ./config/lua/telescope.lua;
    extern = with pkgs; [ ripgrep ];
  };

  treesitter = {
    plugin = addDeps (nvim-treesitter.withPlugins (_: pkgs.unstable.tree-sitter.allGrammars)) [
      nvim-autopairs
      nvim-treesitter-textobjects
      pkgs.custom.nvim-ts-autotag
    ];
    config = ./config/lua/treesitter.lua;
  };

  nvim-tree = {
    plugin = nvim-tree-lua;
  };

  nvim-lspconfig = {
    plugin = addDeps nvim-lspconfig [
      lsp_extensions-nvim
      lsp_signature-nvim
    ];
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
  };

  vim-easy-align = {
    plugin = vim-easy-align;
    config = ./config/lua/easy-align.lua;
  };

  gitsigns-nvim = {
    plugin = gitsigns-nvim;
    config = ./config/lua/gitsigns-nvim.lua;
  };

  nvim-autopairs = {
    plugin = nvim-autopairs;
    config = ./config/lua/nvim-autopairs.lua;
  };

  nvim-colorizer = {
    plugin = nvim-colorizer-lua;
    config = ./config/lua/nvim-colorizer.lua;
  };

  comment-nvim = {
    plugin = comment-nvim;
    config = ./config/lua/comment-nvim.lua;
  };

  editorconfig-vim.plugin = editorconfig-vim;
  vim-surround.plugin = vim-surround;
  vim-repeat.plugin = vim-repeat;
  vim-fugitive.plugin = vim-fugitive;
}
