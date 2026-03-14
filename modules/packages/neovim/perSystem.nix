{ ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      mkNeovim = pkgs.unstable.callPackage ./_mkNeovim.nix { };

      plugins = with pkgs.unstable.vimPlugins; [
        # lazy-load plugins https://github.com/BirdeeHub/lze
        lze

        # style
        kanagawa-nvim
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

        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        nvim-ts-context-commentstring
        mini-nvim

        # python stuff??
        molten-nvim
        image-nvim
        quarto-nvim
        pkgs.custom.NotebookNavigator-nvim
      ];

      extraPackages = with pkgs.unstable; [
        # language servers
        basedpyright
        gopls
        lua-language-server
        markdown-oxide
        nil
        nodePackages.yaml-language-server
        ruby-lsp
        typescript-language-server
        terraform-ls

        # formatters
        nixfmt
        stylua

        pkgs.gitlab-reviewer

        # also python stuff for molten??
        imagemagick
      ];

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

      immutableConfig = ./config;

      outOfStoreConfig = "/home/max/nixconfig/modules/packages/neovim/config";
    in
    {
      packages = {
        nvim-mutable = mkNeovim {
          inherit
            plugins
            extraPackages
            extraPython3Packages
            extraLuaPackages
            outOfStoreConfig
            ;

          appName = "nv";
        };

        nvim = mkNeovim {
          inherit
            plugins
            extraPackages
            extraPython3Packages
            extraLuaPackages
            immutableConfig
            ;

          appName = "nvim"; # nv IM-mutable
        };
      };
    };
}
