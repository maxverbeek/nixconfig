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
      ];

      extraPackages = with pkgs.unstable; [
        # language servers
        lua-language-server
        nodePackages.yaml-language-server

        pkgs.gitlab-reviewer
      ];

      immutableConfig = ./config;

      outOfStoreConfig = "/home/max/dendritic/modules/packages/neovim/config";
    in
    {
      packages = {
        nvim-mutable = mkNeovim {
          inherit plugins extraPackages outOfStoreConfig;
          appName = "nv";
        };

        nvim = mkNeovim {
          inherit plugins extraPackages immutableConfig;
          appName = "nvim"; # nv IM-mutable
        };
      };
    };
}
