{ config, lib, ... }:
let cfg = config.modules.hyprland;
in {

  options.modules.hyprland.enable = lib.mkEnableOption null;

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      enableNvidiaPatches = true;

      extraConfig = ''
        source = ~/.config/hypr/actualconfig.conf
      '';
    };
  };
}
