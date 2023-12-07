{ pkgs, config, lib, ... }:
let cfg = config.modules.hyprland;
in {

  options.modules.hyprland.enable = lib.mkEnableOption null;

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      extraConfig = ''
        source = ~/.config/hypr/actualconfig.conf
      '';
    };

    home.packages = with pkgs; [
      swaybg
      unstable.waybar
      blueberry
      networkmanagerapplet
      xdg-launch # xdg-open
      xdg-utils
    ];
  };
}
