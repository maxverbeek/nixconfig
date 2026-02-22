{ ... }:
{
  # Device options declarations for home-manager modules
  # These options allow per-host customization of HM modules (screens, battery, wifi, etc.)
  flake.modules.homeManager.deviceOptions =
    { config, lib, ... }:
    let
      cfg = config.device;

      screenType = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "The name of the monitor as given by xrandr/wayland";
            example = "DP-2";
          };
          isPrimary = lib.mkOption {
            type = lib.types.bool;
            description = "Whether this monitor is the primary monitor";
            default = false;
          };
        };
      };
    in
    {
      options.device = {
        screens = lib.mkOption {
          type = lib.types.listOf screenType;
          description = "All monitors plugged in";
          default = [ ];
        };

        hyprland.enable = lib.mkEnableOption "Hyprland config";

        wifi = {
          enabled = lib.mkEnableOption "wifi" // {
            description = "Whether wifi is enabled";
          };
          interface = lib.mkOption {
            type = lib.types.str;
            description = "The name of the wifi interface";
            default = "";
          };
        };

        hasBattery = lib.mkOption {
          type = lib.types.bool;
          description = "Whether the device has a battery";
          default = false;
        };

        hasBrightness = lib.mkOption {
          type = lib.types.bool;
          description = "Whether the screen can change brightness";
          default = false;
        };

        withScreenLocker = lib.mkEnableOption "screenlocker";

        termFontSize = lib.mkOption {
          type = lib.types.int;
          description = "The size of the font (pt) in terminals";
          default = 11;
        };
      };

      config.assertions = [
        {
          assertion = builtins.length cfg.screens > 0;
          message = "at least 1 screen has to be enabled";
        }
        {
          assertion = builtins.length (builtins.filter (s: s.isPrimary) cfg.screens) == 1;
          message = "the number of primary screens must be 1";
        }
        {
          assertion = !cfg.wifi.enabled || cfg.wifi.interface != "";
          message = "if wifi is supported, a wifi interface needs to be provided";
        }
      ];
    };
}
