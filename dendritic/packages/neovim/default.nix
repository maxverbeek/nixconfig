{ ... }:
{
  perSystem =
    {
      pkgs,
      unstable,
      lib,
      ...
    }:
    let
      mkNeovim = unstable.callPackage ./_mkNeovim.nix { };

      plugins = with unstable.vimPlugins; [
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

      extraPackages = with unstable; [
        # language servers
        lua-language-server
        nodePackages.yaml-language-server

        pkgs.gitlab-reviewer
      ];

      immutableConfig = ./config;

      outOfStoreConfig = "/home/max/dendritic/dendritic/packages/neovim/config";
    in
    {
      packages = {
        nvim-mutable = mkNeovim {
          inherit plugins extraPackages;
          inherit outOfStoreConfig;
          appName = "nv";
        };

        nvim-immut = mkNeovim {
          inherit plugins extraPackages;
          inherit immutableConfig;
          appName = "nvim-immut";
        };
      };
    };
}
