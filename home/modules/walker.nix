{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

in
{
  options.modules.walker = {
    enable = mkEnableOption "enable walker";
  };

  config = mkIf config.modules.walker.enable {
    programs.walker = {
      enable = true;
      runAsService = true; # Note: this option isn't supported in the NixOS module only in the home-manager module

      # All options from the config.toml can be used here https://github.com/abenz1267/walker/blob/master/resources/config.toml
      config = {
        placeholders."default" = {
          input = "Search";
          list = "Example";
        };
        providers.prefixes = [
          {
            provider = "websearch";
            prefix = "+";
          }
          {
            provider = "providerlist";
            prefix = "_";
          }
        ];

        keybinds = {
          quick_activate = [
            "F1"
            "F2"
            "F3"
          ];

          next = [
            "Down"
            "ctrl j"
          ];
          previous = [
            "Up"
            "ctrl k"
          ];

          left = [
            "Left"
            "ctrl h"
          ];
          right = [
            "Right"
            "ctrl l"
          ];
          down = [
            "Down"
            "ctrl j"
          ];
          up = [
            "Up"
            "ctrl k"
          ];
        };
      };

      # Set `programs.walker.config.theme="your theme name"` to choose the default theme
      themes = { };
    };
  };
}
