{ lib, ... }:

with lib;

let

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
        # check = with builtins; (scrns: length scrns > 0 && length (filter (s: s.isPrimary) scrns) == 1);
        description = "All the monitors plugged in. Dunno yet what to do about external monitors";
        example = literalExample ''
          screens = [
            { name = "DP-2"; isPrimary = true; }
            { name = "DP-4"; isPrimary = false; }
            { name = "DP-3"; }
          ];
        '';
        default = [];
      };

      hasWifi = mkOption {
        type = types.bool;
        description = "Whether the device has wifi or not";
        default = false;
        example = true;
      };

      hasBattery = mkOption {
        type = types.bool;
        description = "Whether the device has a battery";
        default = false;
        example = true;
      };
    };
  };
}
