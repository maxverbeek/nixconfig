{ config, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      mkNeovim = pkgs.unstable.callPackage ../../../packages/neovim/mk-neovim.nix { };
      mkConfigSource = pkgs.callPackage ../../../packages/mk-config-source.nix { };

      configDir = ../../../packages/neovim/config;

      plugins = with pkgs.unstable.vimPlugins; [
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
        pkgs.custom.NotebookNavigator-nvim
      ];

      extraPackages = with pkgs.unstable; [
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

        pkgs.gitlab-reviewer

        # ruby_lsp is launched via `direnv exec` (see after/lsp/ruby_lsp.lua)
        direnv

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

      # Everything both variants share. Only `config` and `appName` differ.
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
      packages = {
        # Config from the store: reproducible, works without the repo checked out.
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
              impure = "${config.flake.lib.repoRoot}/packages/neovim/config";
            };
            appName = "nv"; # nv IM-mutable
          }
        );
      };
    };
}
