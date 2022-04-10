{ lib, ... }: {
  options.modules.i3 = with lib; {
    enable = mkEnableOption "i3 window manager";

    mod = mkOption {
      default = "Mod4"; # super key
      description = "The mod key used in i3";
      type = types.str;
      example = "Mod4";
    };
  };
}
