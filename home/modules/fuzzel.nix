{ pkgs, lib, config, ... }:
let
  kanagawa = pkgs.custom.kanagawa-nvim.colors.term;

  # some helpers that turn a color #rrggbb into rrggbbff
  hex2rgba = str:
    builtins.substring 1 (builtins.stringLength str - 1) str + "ff";
  fixcolors = builtins.mapAttrs (name: value: hex2rgba value);

  colors = fixcolors {
    fg = kanagawa.normal.white;
    bg = kanagawa.extended.background;
    match = kanagawa.bright.green;
    border = kanagawa.extended.slate;

    bgselected = kanagawa.normal.teal;
  };

in {
  options = { modules.fuzzel.enable = lib.mkEnableOption "Enable fuzzel"; };

  config = lib.mkIf config.modules.fuzzel.enable {
    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          width = 30;
          lines = 15;
          font = "JetBrainsMono Nerd Font:size=12";
        };

        colors = {
          border = colors.border;
          background = colors.bg;
          text = colors.fg;
          match = colors.match;

          selection = colors.bgselected;
          selection-text = colors.fg;
          selection-match = colors.match;
        };

        key-bindings = {
          prev = "Up Control+k";
          next = "Down Control+j";
          delete-line = "Control+d";
          delete-next = "Delete";
        };
      };
    };
  };
}
