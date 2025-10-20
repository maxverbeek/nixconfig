final:
{
  system,
  lib,
  callPackage,
  vimPlugins,
  vimUtils,
  ...
}:

let
  # Use this to create a plugin from a flake input
  buildVimPlugin =
    src: pname:
    vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = callPackage ../lib/mkNeovim.nix { };

  plugins =
    let
      # The `start` plugins are loaded on nvim startup automatically.
      # It is the default. `(start plugin)` is equivalent to `plugin`.
      start = x: {
        plugin = x;
        optional = false;
      };
      # The `opt` plugins are to be loaded with `packadd` command.
      # If you want to lazy-load a plugin, then make it `opt`.
      opt = x: {
        plugin = x;
        optional = true;
      };
    in
    with vimPlugins;
    [
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

  extraPackages = with final; [
    # language servers
    lua-language-server
    nodePackages.yaml-language-server
  ];

  immutableConfig = ./config;

  # A string with an absolute path to config directory, to bypass the nix store.
  outOfStoreConfig = "/home/max/nixconfig/neovim/config";
in
{
  # This package uses config files directly from `configPath`
  # Restart nvim to apply changes in config
  nvim-mutable = mkNeovim {
    inherit plugins extraPackages;
    inherit outOfStoreConfig;
    appName = "nv";
  };

  # This package uses the config files saved in nix store
  # Rebuild to apply changes in config: e.g. `nix run .#nvim-sealed`
  nvim-immut = mkNeovim {
    inherit plugins extraPackages;
    inherit immutableConfig;
    appName = "nvim-immut";
    # aliases = [
    #   "nvim" # im for immutable :P
    # ];
  };
}
