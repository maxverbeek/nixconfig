{ pkgs, config, lib, ... }:
let inherit (config.lib.formats.rasi) mkLiteral;
in {
  options = { modules.rofi.enable = lib.mkEnableOption "Enable rofi"; };

  config = lib.mkIf config.modules.rofi.enable {
    programs.rofi = {
      enable = true;

      theme = {
        "*" = {
          scrollbar = false;
          width = 750;
          lines = 13;
        };
      };

      font = "DejaVu Sans Mono 13";

      extraConfig = {
        modi = "drun,run,window";
        separator-style = "solid";
        show-match = false;
      };
    };
  };
}
