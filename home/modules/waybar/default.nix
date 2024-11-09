{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  modulesnix = import ./modules.nix;
  modulesfile = pkgs.writeText "modules.json" (builtins.toJSON modulesnix);

  waybarconfig = [
    {
      include = [ modulesfile ];
      modules-center = [ "mpris" ];
      modules-left = [
        "hyprland/workspaces"
        "niri/workspaces"
      ];
      modules-right = [
        "bluetooth"
        "battery"
        "network"
        "wireplumber"
        "tray"
        "clock"
      ];
    }
  ];
in
{
  options.modules.waybar = {
    enable = mkEnableOption "enable waybar";
  };

  config = mkIf config.modules.waybar.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.unstable.waybar;
      settings = waybarconfig;
      style = ./style.css;

      systemd.enable = true;
      systemd.target = "hyprland-session.target";
    };

    # make sure this doesnt timeout too fast when hyprland loads slowly
    systemd.user.services.waybar.Service.RestartSec = "3";

    home.packages = with pkgs; [
      unstable.waybar-mpris
      blueberry
      networkmanagerapplet
    ];
  };
}
