{
  pkgs,
  vimPlugins ? pkgs.vimPlugins,
  ...
}:
with vimPlugins;
let
  # update some packages to unstable
  inherit (pkgs.unstable.vimPlugins)
    nvim-autopairs
    nvim-ts-autotag
    formatter-nvim
    conform-nvim
    ;
in
{
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
    plugin = telescope-nvim;
    config = "telescope";
    extern = with pkgs; [
      ripgrep
      fd
    ];

    depend = [
      nvim-web-devicons
      telescope-fzf-native-nvim
      telescope-file-browser-nvim
    ];
  };

  # Tree sitter + treesitter plugins
  treesitter = {
    plugin = nvim-treesitter.withAllGrammars;
    config = "treesitter";
    depend = [
      playground
      nvim-autopairs
      nvim-treesitter-textobjects
    ];
  };

  nvim-ts-autotag = {
    plugin = nvim-ts-autotag;
    config = "nvim-ts-autotag";
  };

  neotree = {
    plugin = neo-tree-nvim;
    config = "nvim-neo-tree";
    depend = [
      nvim-web-devicons
      plenary-nvim
      nui-nvim
    ];
  };

  nvim-lspconfig = {
    plugin = nvim-lspconfig;
    depend = [
      lsp_extensions-nvim
      lsp_signature-nvim
    ];
    config = "lsp";
  };

  nvim-cmp = {
    plugin = nvim-cmp;
    depend = [
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      lspkind-nvim
    ];

    extern = with pkgs; [
      arduino-language-server
      unstable.nil
      unstable.nodePackages.typescript-language-server
      unstable.nodePackages."@tailwindcss/language-server"
      unstable.nodePackages."svelte-language-server"
      unstable.texlab
      rust-analyzer
      gopls
      pyright
      clang-tools
      terraform-ls
      metals
      ocamlPackages.ocaml-lsp
      haskell-language-server
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
    depend = [ nvim-ts-context-commentstring ];
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

  conform-nvim = {
    plugin = conform-nvim;
    config = "formatter";
    extern = with pkgs; [
      nixfmt-rfc-style
      stylua
      unstable.yamlfmt
      custom.rubocop
      custom.nodePackages."@fsouza/prettierd"
      unstable.nodePackages.prettier
      # unstable.nodePackages.vscode-langservers-extracted
      ocamlformat
    ];
  };

  # neoformat = {
  #   plugin = neoformat;
  #   config = "neoformat";
  #   extern = with pkgs; [
  #     nixfmt
  #     custom.rubocop
  #     unstable.nodePackages.prettier
  #     unstable.nodePackages.vscode-langservers-extracted
  #   ];
  # };

  luasnip = {
    plugin = luasnip;
    config = "luasnip";
  };

  dressing-nvim = {
    plugin = dressing-nvim;
    config = "dressing";
  };

  diffview-nvim = {
    plugin = diffview-nvim;
    config = "diffview";
  };

  # viewing notebook stuff in nvim
  molten-nvim = {
    plugin = molten-nvim;
    depend = [ image-nvim ];
    extern =
      let
        pythonpackages = with pkgs.python3Packages; [
          pynvim
          cairosvg
          ipython
          nbformat
          jupyter-client
        ];
      in
      with pkgs;
      [ imagemagick ] ++ pythonpackages;
  };

  editorconfig-vim.plugin = editorconfig-vim;
  vim-surround.plugin = vim-surround;
  vim-repeat.plugin = vim-repeat;
  vim-fugitive = {
    plugin = vim-fugitive;
    depend = [ fugitive-gitlab-vim ];
  };
  vimtext.plugin = vimtex;
}
