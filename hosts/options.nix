{ config, lib, ... }:

with lib;

let

  cfg = config.device;

  screenType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the monitor as given by xrandr";
        example = "DP-2";
      };

      isPrimary = mkOption {
        type = types.bool;
        description = "Whether this monitor is the primary monitor (that contains the system tray)";
        example = true;
        default = false;
      };
    };
  };
in
{
  options = {
    device = {
      screens = mkOption {
        type = types.listOf screenType;
        description = "All the monitors plugged in. Dunno yet what to do about external monitors";
        example = literalExample ''
          screens = [
            { name = "DP-2"; isPrimary = true; }
            { name = "DP-4"; isPrimary = false; }
            { name = "DP-3"; }
          ];
        '';
        default = [ ];
      };

      hyprland.enable = mkEnableOption "Hyprland config";

      wifi = {
        enabled = mkEnableOption "wifi" // {
          description = "Whether wifi is enabled";
        };

        interface = mkOption {
          type = types.str;
          description = "The name of the wifi interface";
          example = "wlp2s0";
          default = "";
        };
      };

      hasBattery = mkOption {
        type = types.bool;
        description = "Whether the device has a battery";
        default = false;
        example = true;
      };

      hasBrightness = mkOption {
        type = types.bool;
        description = "Whether the screen can change brightness";
        default = false;
        example = true;
      };

      withScreenLocker = mkEnableOption "screenlocker";

      termFontSize = mkOption {
        type = types.int;
        description = "The size of the font (pt) in terminals (alacritty)";
        default = 11;
        example = 8;
      };
    };
  };

  config.assertions = [
    {
      assertion = with builtins; length cfg.screens > 0;
      message = "at least 1 screen has to be enabled";
    }

    {
      assertion = with builtins; length (filter (s: s.isPrimary) cfg.screens) == 1;
      message = "the number of primary screens must be 1";
    }

    {
      assertion = !cfg.wifi.enabled || cfg.wifi.interface != "";
      message = "if wifi is supported, a wifi interface needs to be provided";
    }
  ];
}
