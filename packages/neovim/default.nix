{
  pkgs,
  unstable,
  repoRoot,
  gitlab-reviewer,
  NotebookNavigator-nvim,
}:
let
  mkNeovim = unstable.callPackage ./mk-neovim.nix { };
  mkConfigSource = pkgs.callPackage ../mk-config-source.nix { };

  configDir = ./config;

  plugins = with unstable.vimPlugins; [
    # lazy-load plugins https://github.com/BirdeeHub/lze
    lze

    # style
    kanagawa-nvim
    catppuccin-nvim
    dressing-nvim
    fidget-nvim
    nvim-web-devicons

    # completion
    blink-cmp
    nvim-lspconfig
    nvim-ts-autotag

    # AI
    codecompanion-nvim

    luasnip
    conform-nvim

    # navigation
    snacks-nvim
    oil-nvim
    vim-fugitive
    gitsigns-nvim
    diffview-nvim

    # yaml/helm
    vim-helm

    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring
    mini-nvim

    # python stuff??
    molten-nvim
    image-nvim
    quarto-nvim
    NotebookNavigator-nvim
  ];

  extraPackages =
    with unstable;
    [
      # language servers
      basedpyright
      gopls
      lua-language-server
      markdown-oxide
      nil
      yaml-language-server
      helm-ls
      ruby-lsp
      typescript-language-server
      terraform-ls

      # formatters
      nixfmt
      stylua
    ]
    ++ [
      # `with unstable` would shadow this argument: the old overlay also put
      # gitlab-reviewer into unstable. Take the argument, deliberately.
      gitlab-reviewer
    ]
    ++ (with unstable; [
      # ruby_lsp is launched via `direnv exec` (see after/lsp/ruby_lsp.lua)
      direnv

      # also python stuff for molten??
      imagemagick
    ]);

  extraPython3Packages =
    ps: with ps; [
      pynvim
      jupyter-client
      cairosvg
      pnglatex
      plotly
      pyperclip
    ];

  extraLuaPackages =
    ps: with ps; [
      magick
    ];

  common = {
    inherit
      plugins
      extraPackages
      extraPython3Packages
      extraLuaPackages
      ;
  };
in
{
  # Config from the store: works without the repo checked out.
  nvim = mkNeovim (
    common
    // {
      config = mkConfigSource { pure = configDir; };
    }
  );

  # Config read from the working tree: edit lua without a rebuild.
  nvim-mutable = mkNeovim (
    common
    // {
      config = mkConfigSource {
        pure = configDir;
        impure = "${repoRoot}/packages/neovim/config";
      };
      appName = "nv"; # nv IM-mutable
    }
  );
}
