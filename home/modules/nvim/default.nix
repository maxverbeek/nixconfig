{ pkgs, config, lib, ... }:
let
  vimPlugins = pkgs.unstable.vimPlugins;
  configuredPlugins = import ./plugins.nix { inherit pkgs; inherit vimPlugins; };

  plugins = builtins.attrValues configuredPlugins;

  pluginPkgs = let
    plugs = builtins.catAttrs "plugin" plugins;
    transitiveClosure = plugin:
      [ plugin ] ++ (
        lib.unique (builtins.concatLists (map transitiveClosure plugin.dependencies or []))
      );

    deps = lib.concatMap transitiveClosure plugs;
    pkgs = lib.unique (plugs ++ deps);
  in pkgs;

  sourcestr = with builtins; concatStringsSep "\n" (map (x: "source ${x}") (catAttrs "config" plugins));

  externals = builtins.concatLists (builtins.catAttrs "extern" plugins);

  nvim = (pkgs.unstable.neovim.override {
    configure = {
      plug.plugins = pluginPkgs;

      customRC = ''
        set runtimepath^=${./config}
        source ${./config/lua/init.lua}
      '';
    };
  }).overrideAttrs (_: {
    passthru.additionalPackages = externals;
  });

in
{
  home.packages = [ nvim ] ++ nvim.additionalPackages;
}
