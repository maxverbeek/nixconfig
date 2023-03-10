{ pkgs, config, lib, ... }:
let
  vimPlugins = pkgs.vimPlugins;
  configuredPlugins = import ./plugins.nix {
    inherit pkgs;
    inherit vimPlugins;
  };

  plugins = builtins.attrValues configuredPlugins;

  pluginPkgs = let
    plugs = builtins.catAttrs "plugin" plugins;
    deps = builtins.catAttrs "depend" plugins;

    pkgs = lib.unique (plugs ++ deps);
  in pkgs;

  sourcestr = with builtins;
    concatStringsSep "\n"
    (map (x: "require('maxconf.${x}')") (catAttrs "config" plugins));

  externals = with pkgs;
    [
      xclip # for clipboard support
    ] ++ builtins.concatLists (builtins.catAttrs "extern" plugins);

  nvim = (pkgs.neovim.override {
    configure = {
      packages.whatever.start = pluginPkgs;

      customRC = ''
        set runtimepath^=${./config}
        source ${./config/lua/init.lua}

        lua <<EOF
        ${sourcestr}
        EOF
      '';
    };
  }).overrideAttrs (_: { passthru.additionalPackages = externals; });

in { home.packages = [ nvim ] ++ nvim.additionalPackages; }
