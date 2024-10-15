{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkPackageOption mkEnableOption mkIf;

  cfg = config.modules.niri;
in
{
  options.modules.niri = {
    enable = mkEnableOption "Enable Niri tiling window manager";

    package = mkPackageOption pkgs "niri" { extraDescription = "Which package to use for Niri"; };
  };

  config = mkIf config.modules.niri.enable {
    environment.systemPackages = [ cfg.package ];
    services.displayManager.sessionPackages = [ cfg.package ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };
  };
}
