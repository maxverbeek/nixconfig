{ mnw }:
prev: final:
let
  myneovim = mnw.lib.wrap final {
    neovim = final.neovim-unwrapped;
    initLua = ''
      require('myconfig')
    '';
    plugins = {
      start = with final.vimPlugins; [
        # style
        kanagawa-nvim
        dressing-nvim
        fidget-nvim
        nvim-web-devicons

        # completion
        blink-cmp
        nvim-lspconfig
        nvim-ts-autotag

        luasnip
        conform-nvim

        # navigation
        snacks-nvim
        oil-nvim
        fugitive
        gitsigns-nvim
        diffview-nvim

        nvim-treesitter.withAllGrammars
        nvim-ts-context-commentstring
        mini-nvim
      ];

      dev.myconfig = {
        pure = ./config;
        impure = "/home/max/nixconfig/neovim/config";
      };
    };
  };

in
{
  nvim-immut = myneovim.overrideAttrs { aliases = "nvim-immut"; };
  nvim-mut = myneovim.devMode.overrideAttrs { aliases = "nv"; };
}
